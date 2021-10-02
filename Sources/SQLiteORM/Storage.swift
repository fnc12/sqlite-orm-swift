import Foundation

public protocol Initializable {
    init()
}

public class Storage: NSObject {
    private let tables: [AnyTable]
    private let inMemory: Bool
    let connection: ConnectionHolder
    private let apiProvider: SQLiteApiProvider
    
    init(filename: String, apiProvider: SQLiteApiProvider, connection: ConnectionHolder, tables: [AnyTable]) throws {
        self.inMemory = filename.isEmpty || filename == ":memory:"
        self.tables = tables
        self.connection = connection
        self.apiProvider = apiProvider
        super.init()
        if self.inMemory {
            try self.connection.increment()
        }
    }
    
    convenience init(filename: String, apiProvider: SQLiteApiProvider, tables: [AnyTable]) throws {
        try self.init(filename: filename, apiProvider: apiProvider, connection: ConnectionHolderImpl(filename: filename, apiProvider: apiProvider), tables: tables)
    }
    
    public convenience init(filename: String, tables: AnyTable...) throws {
        try self.init(filename: filename, apiProvider: SQLiteApiProviderImpl.shared, tables: tables)
    }
    
    deinit {
        if self.inMemory {
            self.connection.decrementUnsafe()
        }
    }
    
    public var filename: String {
        return self.connection.filename
    }
    
    public func tableExists(with name: String) throws -> Bool {
        let connectionRef = try ConnectionRef(connection: self.connection)
        return try self.tableExists(with: name, connectionRef: connectionRef)
    }
    
    private func tableExists(with name: String, connectionRef: ConnectionRef) throws -> Bool {
        var res = false
        let sql = "SELECT COUNT(*) FROM sqlite_master WHERE type = 'table' AND name = '\(name)'"
        let statement = try connectionRef.prepare(sql: sql)
        var resultCode = Int32(0)
        repeat {
            resultCode = statement.step()
            switch resultCode {
            case apiProvider.SQLITE_ROW:
                let intValue = statement.columnInt(index: 0)
                res = intValue == 1
            case apiProvider.SQLITE_DONE:
                break
            default:
                let errorString = connectionRef.errorMessage
                throw Error.sqliteError(code: resultCode, text: errorString)
            }
        }while resultCode != apiProvider.SQLITE_DONE
        return res
    }
    
    private func tableInfo(forTableWith name: String, connectionRef: ConnectionRef) throws -> [TableInfo] {
        let sql = "PRAGMA table_info('\(name)')"
        let statement = try connectionRef.prepare(sql: sql)
        var res = [TableInfo]()
        var resultCode = Int32(0)
        repeat {
            resultCode = statement.step()
            switch resultCode {
            case apiProvider.SQLITE_ROW:
                var tableInfo = TableInfo()
                tableInfo.cid = statement.columnInt(index: 0)
                tableInfo.name = statement.columnText(index: 1)
                tableInfo.type = statement.columnText(index: 2)
                tableInfo.notNull = statement.columnInt(index: 3) == 1
                tableInfo.dfltValue = statement.columnText(index: 4)
                tableInfo.pk = statement.columnInt(index: 5)
                res.append(tableInfo)
            case apiProvider.SQLITE_DONE:
                break
            default:
                let errorString = connectionRef.errorMessage
                throw Error.sqliteError(code: resultCode, text: errorString)
            }
        }while resultCode != apiProvider.SQLITE_DONE
        return res
    }
    
    static private func calculateRemoveAddColumns(columnsToAdd: inout [TableInfo],
                                                  storageTableInfo: inout [TableInfo],
                                                  dbTableInfo: inout [TableInfo]) -> Bool {
        var notEqual = false
        
        //  iterate through storage columns
        var storageColumnInfoIndex = 0
        repeat {
            
            //  get storage's column info
            let storageColumnInfo = storageTableInfo[storageColumnInfoIndex]
            let columnName = storageColumnInfo.name
            
            //  search for a column in db eith the same name
            if let dbColumnInfo = dbTableInfo.first(where: { $0.name == columnName }) {
                let columnsAreEqual = dbColumnInfo.name == storageColumnInfo.name
                    && dbColumnInfo.notNull == storageColumnInfo.notNull
                    && dbColumnInfo.dfltValue.isEmpty == storageColumnInfo.dfltValue.isEmpty
                    && dbColumnInfo.pk == storageColumnInfo.pk
                if !columnsAreEqual {
                    notEqual = true
                    break
                }
                dbTableInfo.removeAll(where: { $0.name == columnName })
                storageTableInfo.remove(at: storageColumnInfoIndex)
                storageColumnInfoIndex -= 1
            }else{
                columnsToAdd.append(storageColumnInfo)
            }
            
            storageColumnInfoIndex += 1
        }while storageColumnInfoIndex < storageTableInfo.count
        
        return notEqual
    }
    
    private func schemaStatus(for table: AnyTable, connectionRef: ConnectionRef, preserve: Bool) throws -> SyncSchemaResult {
        var res = SyncSchemaResult.alredyInSync
        var gottaCreateTable = try !self.tableExists(with: table.name, connectionRef: connectionRef)
        if !gottaCreateTable {
            var storageTableInfo = table.tableInfo
            var dbTableInfo = try self.tableInfo(forTableWith: table.name, connectionRef: connectionRef)
            var columnsToAdd = [TableInfo]()
            if Storage.calculateRemoveAddColumns(columnsToAdd: &columnsToAdd, storageTableInfo: &storageTableInfo, dbTableInfo: &dbTableInfo) {
                gottaCreateTable = true
            }
            if !gottaCreateTable {  //  if all storage columns are equal to actual db columns but there are
                //  excess columns at the db..
                if dbTableInfo.count > 0 {
                    // extra table columns than storage columns
                    if !preserve {
                        gottaCreateTable = true
                    }else{
                        res = .oldColumnsRemoved
                    }
                }
            }
            if gottaCreateTable {
                res = .droppedAndRecreated
            }else{
                if !columnsToAdd.isEmpty {
                    // extra storage columns than table columns
                    for columnToAdd in columnsToAdd {
                        if columnToAdd.notNull && columnToAdd.dfltValue.isEmpty {
                            gottaCreateTable = true
                            break
                        }
                    }
                    if !gottaCreateTable {
                        if res == .oldColumnsRemoved {
                            res = .newColumnsAddedAndOldColumnsRemoved
                        }else{
                            res = .newColumnsAdded
                        }
                    }else{
                        res = .droppedAndRecreated
                    }
                }else{
                    if res != .oldColumnsRemoved {
                        res = .alredyInSync
                    }
                }
            }
        }else{
            res = .newTableCreated
        }
        return res
    }
    
    private func create(tableWith name: String, columns:[AnyColumn], connectionRef: ConnectionRef) throws {
        var sql = "CREATE TABLE '\(name)' ("
        let columnsCount = columns.count
        for (columnIndex, column) in columns.enumerated() {
            let columnString = serialize(column: column)
            sql += "\(columnString)"
            if columnIndex < columnsCount - 1 {
                sql += ", "
            }
        }
        sql += ")"
        try connectionRef.exec(sql: sql)
    }
    
    private func copy(table: AnyTable, name: String, connectionRef: ConnectionRef, columnsToIgnore: [TableInfo]) throws {
        var columnNames = [String]()
        for column in table.columns {   //  TODO: refactor to map and filter
            let columnName = column.name
            if !columnsToIgnore.contains(where: { $0.name == columnName }) {
                columnNames.append(columnName)
            }
        }
        let columnNamesCount = columnNames.count
        var sql = "INSERT INTO \(name) ("
        for (columnNameIndex, columnName) in columnNames.enumerated() {
            sql += columnName
            if columnNameIndex < columnNamesCount - 1 {
                sql += ", "
            }
        }
        sql += ") SELECT "
        for (columnNameIndex, columnName) in columnNames.enumerated() {
            sql += columnName
            if columnNameIndex < columnNamesCount - 1 {
                sql += ", "
            }
        }
        sql += " FROM '\(table.name)'"
        try connectionRef.exec(sql: sql)
    }
    
    private func dropTableInternal(tableName: String, connectionRef: ConnectionRef) throws {
        let sql = "DROP TABLE '\(tableName)'"
        try connectionRef.exec(sql: sql)
    }
    
    private func renameTable(connectionRef: ConnectionRef, oldName: String, newName: String) throws {
        let sql = "ALTER TABLE \(oldName) RENAME TO \(newName)"
        try connectionRef.exec(sql: sql)
    }
    
    private func backup(_ table: AnyTable, connectionRef: ConnectionRef, columnsToIgnore: [TableInfo]) throws {
        
        //  here we copy source table to another with a name with '_backup' suffix, but in case table with such
        //  a name already exists we append suffix 1, then 2, etc until we find a free name..
        var backupTableName = "\(table.name)_backup"
        if try self.tableExists(with: backupTableName, connectionRef: connectionRef) {
            var suffix = 1
            repeat {
                let anotherBackupTableName = "\(backupTableName)\(suffix)"
                if try self.tableExists(with: anotherBackupTableName, connectionRef: connectionRef) == false {
                    backupTableName = anotherBackupTableName
                    break
                }
                suffix += 1
            }while true
        }
        try self.create(tableWith: backupTableName, columns: table.columns, connectionRef: connectionRef)
        try self.copy(table: table, name: backupTableName, connectionRef: connectionRef, columnsToIgnore: columnsToIgnore)
        try self.dropTableInternal(tableName: table.name, connectionRef: connectionRef)
        try self.renameTable(connectionRef:connectionRef, oldName: backupTableName, newName: table.name)
    }
    
    private func add(column tableInfo: TableInfo, table: AnyTable, connectionRef: ConnectionRef) throws {
        var sql = "ALTER TABLE \(table.name) ADD COLUMN \(tableInfo.name) \(tableInfo.type)"
        if tableInfo.pk == 1 {
            sql += " PRIMARY KEY"
        }
        if tableInfo.notNull {
            sql += " NOT NULL"
        }
        if !tableInfo.dfltValue.isEmpty {
            sql += " DEFAULT \(tableInfo.dfltValue)"
        }
        try connectionRef.exec(sql: sql)
    }
    
    private func sync(_ table: AnyTable, connectionRef: ConnectionRef, preserve: Bool) throws -> SyncSchemaResult {
        var res = SyncSchemaResult.alredyInSync
        let schemaStatus = try self.schemaStatus(for: table, connectionRef: connectionRef, preserve: preserve)
        if schemaStatus != .alredyInSync {
            if schemaStatus == .newTableCreated {
                try self.create(tableWith: table.name, columns: table.columns, connectionRef: connectionRef)
                res = .newTableCreated
            }else{
                if schemaStatus == .oldColumnsRemoved || schemaStatus == .newColumnsAdded || schemaStatus == .newColumnsAddedAndOldColumnsRemoved {
                    
                    //  get table info provided in `make_table` call..
                    var storageTableInfo = table.tableInfo
                    
                    //  now get current table info from db using `PRAGMA table_info` query..
                    var dbTableInfo = try self.tableInfo(forTableWith: table.name, connectionRef: connectionRef)
                    
                    //  this array will contain pointers to columns that gotta be added..
                    var columnsToAdd = [TableInfo]()
                    
                    _ = Storage.calculateRemoveAddColumns(columnsToAdd: &columnsToAdd, storageTableInfo: &storageTableInfo, dbTableInfo: &dbTableInfo)
                    
                    if schemaStatus == .oldColumnsRemoved {
                        
                        //  extra table columns than storage columns
                        try self.backup(table, connectionRef: connectionRef, columnsToIgnore: [])
                        res = .oldColumnsRemoved
                    }
                    
                    if schemaStatus == .newColumnsAdded {
                        for columnToAdd in columnsToAdd {
                            try self.add(column: columnToAdd, table: table, connectionRef: connectionRef)
                        }
                        res = .newColumnsAdded
                    }
                    
                    if schemaStatus == .newColumnsAddedAndOldColumnsRemoved {
                        
                        // remove extra columns
                        try self.backup(table, connectionRef: connectionRef, columnsToIgnore: columnsToAdd)
                        res = .newColumnsAddedAndOldColumnsRemoved
                    }
                }else if schemaStatus == .droppedAndRecreated {
                    try self.dropTableInternal(tableName: table.name, connectionRef: connectionRef)
                    try self.create(tableWith: table.name, columns: table.columns, connectionRef: connectionRef)
                    res = .droppedAndRecreated
                }
            }
        }
        return res
    }
    
    @discardableResult
    public func syncSchema(preserve: Bool) throws -> [String : SyncSchemaResult] {
        let connectionRef = try ConnectionRef(connection: self.connection)
        
        var res = [String : SyncSchemaResult]()
        res.reserveCapacity(self.tables.count)
        for table in self.tables {
            let tableSyncResult = try self.sync(table, connectionRef: connectionRef, preserve: preserve)
            res[table.name] = tableSyncResult
        }
        
        return res
    }
    
    public func getAll<T>() throws -> [T] where T: Initializable {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            throw Error.typeIsNotMapped
        }
        let sql = "SELECT * FROM \(anyTable.name)"
        let connectionRef = try ConnectionRef(connection: self.connection)
        let statement = try connectionRef.prepare(sql: sql)
        let table = anyTable as! Table<T>
        var result = [T]()
        var resultCode: Int32 = 0
        repeat {
            resultCode = statement.step()
            let columnsCount = statement.columnCount()
            guard columnsCount == table.columns.count else {
                throw Error.columnsCountMismatch(statementColumnsCount: Int(columnsCount), storageColumnsCount: table.columns.count)
            }
            switch resultCode {
            case self.apiProvider.SQLITE_ROW:
                var object = T()
                for (columnIndex, anyColumn) in table.columns.enumerated() {
                    let columnValuePointer = statement.columnValuePointer(with: columnIndex)
                    try anyColumn.assign(object: &object, sqliteValue: columnValuePointer)
                }
                result.append(object)
            case self.apiProvider.SQLITE_DONE:
                break
            default:
                let errorString = connectionRef.errorMessage
                throw Error.sqliteError(code: resultCode, text: errorString)
            }
        } while resultCode != apiProvider.SQLITE_DONE
        return result
    }
    
    public func delete<T>(object: T) throws {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            throw Error.typeIsNotMapped
        }
        let primaryKeyColumnNames = anyTable.primaryKeyColumnNames
        guard !primaryKeyColumnNames.isEmpty else {
            throw Error.unableToDeleteObjectWithoutPrimaryKeys
        }
        var sql = "DELETE FROM '\(anyTable.name)' WHERE"
        for (primaryKeyColumnNameIndex, primaryKeyColumnName) in primaryKeyColumnNames.enumerated() {
            sql += " \"" + primaryKeyColumnName + "\" = ?"
            if primaryKeyColumnNameIndex < primaryKeyColumnNames.count - 1 {
                sql += " AND"
            }
        }
        let connectionRef = try ConnectionRef(connection: self.connection)
        let statement = try connectionRef.prepare(sql: sql)
        var bindIndex = 1
        var resultCode = Int32(0)
        for column in anyTable.columns {
            if column.isPrimaryKey {
                let binder = BinderImpl(columnIndex: bindIndex, columnBinder: statement)
                resultCode = try column.bind(binder: binder, object: object)
                guard resultCode == self.apiProvider.SQLITE_OK else {
                    let errorString = connectionRef.errorMessage
                    throw Error.sqliteError(code: resultCode, text: errorString)
                }
                bindIndex += 1
            }
        }
        resultCode = statement.step()
        guard self.apiProvider.SQLITE_DONE == resultCode else {
            let errorString = connectionRef.errorMessage
            throw Error.sqliteError(code: resultCode, text: errorString)
        }
    }
    
    public func update<T>(object: T) throws {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            throw Error.typeIsNotMapped
        }
        let primaryKeyColumnNames = anyTable.primaryKeyColumnNames
        guard !primaryKeyColumnNames.isEmpty else {
            throw Error.unableToGetObjectWithoutPrimaryKeys
        }
        var sql = "UPDATE '\(anyTable.name)' SET"
        var setColumnNames = [String]()
        for column in anyTable.columns {
            if !column.isPrimaryKey {
                setColumnNames.append(column.name)
            }
        }
        for (columnIndex, columnName) in setColumnNames.enumerated() {
            sql += " \"\(columnName)\" = ?"
            if columnIndex < setColumnNames.count - 1 {
                sql += ", "
            }
        }
        sql += " WHERE"
        for (primaryKeyColumnNameIndex, primaryKeyColumnName) in primaryKeyColumnNames.enumerated() {
            sql += " \"" + primaryKeyColumnName + "\" = ?"
            if primaryKeyColumnNameIndex < primaryKeyColumnNames.count - 1 {
                sql += " AND"
            }
        }
        let connectionRef = try ConnectionRef(connection: self.connection)
        let statement = try connectionRef.prepare(sql: sql)
        var bindIndex = 1
        var resultCode = Int32(0)
        for column in anyTable.columns {
            if !column.isPrimaryKey {
                let binder = BinderImpl(columnIndex: bindIndex, columnBinder: statement)
                resultCode = try column.bind(binder: binder, object: object)
                guard resultCode == self.apiProvider.SQLITE_OK else {
                    let errorString = connectionRef.errorMessage
                    throw Error.sqliteError(code: resultCode, text: errorString)
                }
                bindIndex += 1
            }
        }
        for column in anyTable.columns {
            if column.isPrimaryKey {
                let binder = BinderImpl(columnIndex: bindIndex, columnBinder: statement)
                resultCode = try column.bind(binder: binder, object: object)
                bindIndex += 1
                guard resultCode == self.apiProvider.SQLITE_OK else {
                    let errorString = connectionRef.errorMessage
                    throw Error.sqliteError(code: resultCode, text: errorString)
                }
            }
        }
        resultCode = statement.step()
        guard apiProvider.SQLITE_DONE == resultCode else {
            let errorString = connectionRef.errorMessage
            throw Error.sqliteError(code: resultCode, text: errorString)
        }
    }
    
    public func get<T>(id: Bindable...) throws -> T? where T: Initializable {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            throw Error.typeIsNotMapped
        }
        let primaryKeyColumnNames = anyTable.primaryKeyColumnNames
        guard !primaryKeyColumnNames.isEmpty else {
            throw Error.unableToGetObjectWithoutPrimaryKeys
        }
        var sql = "SELECT "
        let columnsCount = anyTable.columns.count
        for (columnIndex, column) in anyTable.columns.enumerated() {
            sql += column.name
            if columnIndex < columnsCount - 1 {
                sql += ", "
            }
        }
        sql += " FROM '\(anyTable.name)' WHERE"
        for (primaryKeyColumnNameIndex, primaryKeyColumnName) in primaryKeyColumnNames.enumerated() {
            sql += " \"" + primaryKeyColumnName + "\" = ?"
            if primaryKeyColumnNameIndex < primaryKeyColumnNames.count - 1 {
                sql += " AND"
            }
        }
        let connectionRef = try ConnectionRef(connection: self.connection)
        let statement = try connectionRef.prepare(sql: sql)
        var resultCode: Int32 = 0
        for (idIndex, idValue) in id.enumerated() {
            let columnBinder = BinderImpl(columnIndex: idIndex + 1, columnBinder: statement)
            resultCode = idValue.bind(to: columnBinder)
            guard resultCode == self.apiProvider.SQLITE_OK else {
                let errorString = connectionRef.errorMessage
                throw Error.sqliteError(code: resultCode, text: errorString)
            }
        }
        resultCode = statement.step()
        switch resultCode {
        case self.apiProvider.SQLITE_ROW:
            let table = anyTable as! Table<T>
            var object = T()
            for (columnIndex, anyColumn) in table.columns.enumerated() {
                let sqliteValue = statement.columnValue(columnIndex: columnIndex)
                guard sqliteValue.isValid else {
                    throw Error.valueIsNull
                }
                try anyColumn.assign(object: &object, sqliteValue: sqliteValue)
            }
            return object
        case self.apiProvider.SQLITE_DONE:
            return nil
        default:
            let errorString = connectionRef.errorMessage
            throw Error.sqliteError(code: resultCode, text: errorString)
        }
    }
    
    public func insert<T>(object: T) throws -> Int64 {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            throw Error.typeIsNotMapped
        }
        var sql = "INSERT INTO \(anyTable.name) ("
        let nonPrimaryKeyColumnNamesCount = anyTable.nonPrimaryKeyColumnNamesCount
        anyTable.forEachNonPrimaryKeyColumn { column, columnIndex in
            sql += column.name
            if columnIndex < nonPrimaryKeyColumnNamesCount - 1 {
                sql += ", "
            }
        }
        sql += ") VALUES ("
        for columnIndex in 0..<nonPrimaryKeyColumnNamesCount {
            sql += "?"
            if columnIndex < nonPrimaryKeyColumnNamesCount - 1 {
                sql += ", "
            }
        }
        sql += ")"
        let connectionRef = try ConnectionRef(connection: self.connection)
        let statement = try connectionRef.prepare(sql: sql)
        let table = anyTable as! Table<T>
        var resultCode = try table.bindNonPrimaryKey(columnBinder: statement, object: object, apiProvider: self.apiProvider)
        guard resultCode == apiProvider.SQLITE_OK else {
            let errorString = connectionRef.errorMessage
            throw Error.sqliteError(code: resultCode, text: errorString)
        }
        resultCode = statement.step()
        guard apiProvider.SQLITE_DONE == resultCode else {
            let errorString = connectionRef.errorMessage
            throw Error.sqliteError(code: resultCode, text: errorString)
        }
        return connectionRef.lastInsertRowid
    }
    
    public func replace<T>(object: T) throws {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            throw Error.typeIsNotMapped
        }
        var sql = "REPLACE INTO \(anyTable.name) ("
        let columnsCount = anyTable.columns.count
        for (columnIndex, column) in anyTable.columns.enumerated() {
            sql += column.name
            if columnIndex < columnsCount - 1 {
                sql += ", "
            }
        }
        sql += ") VALUES ("
        for columnIndex in 0..<columnsCount {
            sql += "?"
            if columnIndex < columnsCount - 1 {
                sql += ", "
            }
        }
        sql += ")"
        let connectionRef = try ConnectionRef(connection: self.connection)
        let statement = try connectionRef.prepare(sql: sql)
        let table = anyTable as! Table<T>
        var resultCode = try table.bind(columnBinder: statement, object: object, apiProvider: self.apiProvider)
        guard resultCode == apiProvider.SQLITE_OK else {
            let errorString = connectionRef.errorMessage
            throw Error.sqliteError(code: resultCode, text: errorString)
        }
        resultCode = statement.step()
        guard apiProvider.SQLITE_DONE == resultCode else {
            let errorString = connectionRef.errorMessage
            throw Error.sqliteError(code: resultCode, text: errorString)
        }
    }
}

extension Storage {
    
    public func beginTransaction() throws {
        try self.connection.increment()
        let connectionRef = try ConnectionRef(connection: self.connection)
        try connectionRef.exec(sql: "BEGIN TRANSACTION")
    }
    
    public func commit() throws {
        let connectionRef = try ConnectionRef(connection: self.connection)
        try connectionRef.exec(sql: "COMMIT")
        try self.connection.decrement()
    }
    
    public func rollback() throws {
        let connectionRef = try ConnectionRef(connection: self.connection)
        try connectionRef.exec(sql: "ROLLBACK")
        try self.connection.decrement()
    }
}

extension Storage {
    func minInternal<T, R>(_ columnKeyPath: PartialKeyPath<T>) throws -> R? where R: ConstructableFromSQLiteValue {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            throw Error.typeIsNotMapped
        }
        let table = anyTable as! Table<T>
        guard let column = table.columns.first(where: { $0.keyPath == columnKeyPath }) else {
            throw Error.columnNotFound
        }
        let sql = "SELECT MIN(\(column.name)) FROM \(table.name)"
        let connectionRef = try ConnectionRef(connection: self.connection)
        let statement = try connectionRef.prepare(sql: sql)
        var resultCode = Int32(0)
        var res: R?
        repeat {
            resultCode = statement.step()
            switch resultCode {
            case self.apiProvider.SQLITE_ROW:
                let columnValue = statement.columnValue(columnIndex: 0)
                if !columnValue.isNull {
                    res = R(sqliteValue: columnValue)
                }
            case self.apiProvider.SQLITE_DONE:
                break
            default:
                let errorString = connectionRef.errorMessage
                throw Error.sqliteError(code: resultCode, text: errorString)
            }
        }while resultCode != self.apiProvider.SQLITE_DONE
        return res
    }
    
    public func min<T, F>(_ columnKeyPath: KeyPath<T, Optional<F>>) throws -> F? where F: ConstructableFromSQLiteValue {
        return try self.minInternal(columnKeyPath)
    }
    
    public func min<T, F>(_ columnKeyPath: KeyPath<T, F>) throws -> F? where F: ConstructableFromSQLiteValue {
        return try self.minInternal(columnKeyPath)
    }
    
    func maxInternal<T, R>(_ columnKeyPath: PartialKeyPath<T>) throws -> R? where R: ConstructableFromSQLiteValue {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            throw Error.typeIsNotMapped
        }
        let table = anyTable as! Table<T>
        guard let column = table.columns.first(where: { $0.keyPath == columnKeyPath }) else {
            throw Error.columnNotFound
        }
        let sql = "SELECT MAX(\(column.name)) FROM \(table.name)"
        let connectionRef = try ConnectionRef(connection: self.connection)
        let statement = try connectionRef.prepare(sql: sql)
        var resultCode = Int32(0)
        var res: R?
        repeat {
            resultCode = statement.step()
            switch resultCode {
            case self.apiProvider.SQLITE_ROW:
                let columnValue = statement.columnValue(columnIndex: 0)
                if !columnValue.isNull {
                    res = R(sqliteValue: columnValue)
                }
            case self.apiProvider.SQLITE_DONE:
                break
            default:
                let errorString = connectionRef.errorMessage
                throw Error.sqliteError(code: resultCode, text: errorString)
            }
        }while resultCode != self.apiProvider.SQLITE_DONE
        return res
    }
    
    public func max<T, F>(_ columnKeyPath: KeyPath<T, Optional<F>>) throws -> F? where F: ConstructableFromSQLiteValue {
        return try self.maxInternal(columnKeyPath)
    }
    
    public func max<T, F>(_ columnKeyPath: KeyPath<T, F>) throws -> F? where F: ConstructableFromSQLiteValue {
        return try self.maxInternal(columnKeyPath)
    }
    
    func groupConcatInternal<T, F>(_ columnKeyPath: KeyPath<T, F>, separator: String?) throws -> String? {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            throw Error.typeIsNotMapped
        }
        let table = anyTable as! Table<T>
        guard let column = table.columns.first(where: { $0.keyPath == columnKeyPath }) else {
            throw Error.columnNotFound
        }
        let sql: String
        if nil == separator {
            sql = "SELECT GROUP_CONCAT(\(column.name)) FROM \(table.name)"
        }else{
            sql = "SELECT GROUP_CONCAT(\(column.name), '\(separator!)') FROM \(table.name)"
        }
        let connectionRef = try ConnectionRef(connection: self.connection)
        let statement = try connectionRef.prepare(sql: sql)
        var resultCode = Int32(0)
        var res: String?
        repeat {
            resultCode = statement.step()
            switch resultCode {
            case self.apiProvider.SQLITE_ROW:
                let columnValue = statement.columnValue(columnIndex: 0)
                if !columnValue.isNull {
                    res = columnValue.text
                }
            case self.apiProvider.SQLITE_DONE:
                break
            default:
                let errorString = connectionRef.errorMessage
                throw Error.sqliteError(code: resultCode, text: errorString)
            }
        }while resultCode != self.apiProvider.SQLITE_DONE
        return res
    }
    
    public func groupConcat<T, F>(_ columnKeyPath: KeyPath<T, F>, separator: String) throws -> String? {
        return try self.groupConcatInternal(columnKeyPath, separator: separator)
    }
    
    public func groupConcat<T, F>(_ columnKeyPath: KeyPath<T, F>) throws -> String? {
        return try self.groupConcatInternal(columnKeyPath, separator: nil)
    }
    
    public func count<T, F>(_ columnKeyPath: KeyPath<T, F>) throws -> Int {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            throw Error.typeIsNotMapped
        }
        let table = anyTable as! Table<T>
        guard let column = table.columns.first(where: { $0.keyPath == columnKeyPath }) else {
            throw Error.columnNotFound
        }
        let sql = "SELECT COUNT(\(column.name)) FROM \(table.name)"
        let connectionRef = try ConnectionRef(connection: self.connection)
        let statement = try connectionRef.prepare(sql: sql)
        var resultCode = Int32(0)
        var res = 0
        repeat {
            resultCode = statement.step()
            switch resultCode {
            case self.apiProvider.SQLITE_ROW:
                res = statement.columnInt(index: 0)
            case self.apiProvider.SQLITE_DONE:
                break
            default:
                let errorString = connectionRef.errorMessage
                throw Error.sqliteError(code: resultCode, text: errorString)
            }
        }while resultCode != self.apiProvider.SQLITE_DONE
        return res
    }
    
    public func count<T>(all of:T.Type) throws -> Int {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            throw Error.typeIsNotMapped
        }
        let table = anyTable as! Table<T>
        let sql = "SELECT COUNT(*) FROM \(table.name)"
        let connectionRef = try ConnectionRef(connection: self.connection)
        let statement = try connectionRef.prepare(sql: sql)
        var resultCode = Int32(0)
        var res = 0
        repeat {
            resultCode = statement.step()
            switch resultCode {
            case self.apiProvider.SQLITE_ROW:
                res = statement.columnInt(index: 0)
            case self.apiProvider.SQLITE_DONE:
                break
            default:
                let errorString = connectionRef.errorMessage
                throw Error.sqliteError(code: resultCode, text: errorString)
            }
        }while resultCode != self.apiProvider.SQLITE_DONE
        return res
    }
    
    public func avg<T, F>(_ columnKeyPath: KeyPath<T, F>) throws -> Double? {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            throw Error.typeIsNotMapped
        }
        let table = anyTable as! Table<T>
        guard let column = table.columns.first(where: { $0.keyPath == columnKeyPath }) else {
            throw Error.columnNotFound
        }
        let sql = "SELECT AVG(\(column.name)) FROM \(table.name)"
        let connectionRef = try ConnectionRef(connection: self.connection)
        let statement = try connectionRef.prepare(sql: sql)
        var resultCode = Int32(0)
        var res: Double?
        repeat {
            resultCode = statement.step()
            switch resultCode {
            case self.apiProvider.SQLITE_ROW:
                let columnValue = statement.columnValue(columnIndex: 0)
                if !columnValue.isNull {
                    res = columnValue.double
                }
            case self.apiProvider.SQLITE_DONE:
                break
            default:
                let errorString = connectionRef.errorMessage
                throw Error.sqliteError(code: resultCode, text: errorString)
            }
        }while resultCode != self.apiProvider.SQLITE_DONE
        return res
    }
}
