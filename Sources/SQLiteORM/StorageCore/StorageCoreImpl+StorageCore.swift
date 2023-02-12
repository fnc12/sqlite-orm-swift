import Foundation

extension StorageCoreImpl: StorageCore {
    
    var filename: String {
        self.connection.filename
    }
    
    //  MARK: - Aggregate functions
    
    func total<T, R>(_ columnKeyPath: KeyPath<T, R>, _ constraints: [SelectConstraint]) -> Result<Double, Error> {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            return .failure(Error.typeIsNotMapped)
        }
        let table = anyTable as! Table<T>
        guard let column = table.columnBy(keyPath: columnKeyPath) else {
            return .failure(Error.columnNotFound)
        }
        var sql = "SELECT TOTAL(\"\(column.name)\") FROM \(table.name)"
        for constraint in constraints {
            switch constraint.serialize(with: .init(schemaProvider: self)) {
            case .success(let constraintsString):
                sql += " \(constraintsString)"
            case .failure(let error):
                return .failure(error)
            }
        }
        switch self.connection.createConnectionRef() {
        case .success(let connectionRef):
            switch connectionRef.prepare(sql: sql) {
            case .success(let statement):
                var resultCode = Int32(0)
                var res: Double = 0
                repeat {
                    resultCode = statement.step()
                    switch resultCode {
                    case self.apiProvider.SQLITE_ROW:
                        res = statement.columnDouble(index: 0)
                    case self.apiProvider.SQLITE_DONE:
                        break
                    default:
                        let errorString = connectionRef.errorMessage
                        return .failure(Error.sqliteError(code: resultCode, text: errorString))
                    }
                }while resultCode != self.apiProvider.SQLITE_DONE
                return .success(res)
            case .failure(let error):
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func sum<T, R>(_ columnKeyPath: KeyPath<T, R>, _ constraints: [SelectConstraint]) -> Result<Double?, Error> {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            return .failure(Error.typeIsNotMapped)
        }
        let table = anyTable as! Table<T>
        guard let column = table.columnBy(keyPath: columnKeyPath) else {
            return .failure(Error.columnNotFound)
        }
        var sql = "SELECT SUM(\"\(column.name)\") FROM \(table.name)"
        for constraint in constraints {
            switch constraint.serialize(with: .init(schemaProvider: self)) {
            case .success(let constraintsString):
                sql += " \(constraintsString)"
            case .failure(let error):
                return .failure(error)
            }
        }
        switch self.connection.createConnectionRef() {
        case .success(let connectionRef):
            switch connectionRef.prepare(sql: sql) {
            case .success(let statement):
                var resultCode = Int32(0)
                var res: Double?
                repeat {
                    resultCode = statement.step()
                    switch resultCode {
                    case self.apiProvider.SQLITE_ROW:
                        let columnValue = statement.columnValue(columnIndex: 0)
                        if !columnValue.isNull {
                            res = Double(sqliteValue: columnValue)
                        }
                    case self.apiProvider.SQLITE_DONE:
                        break
                    default:
                        let errorString = connectionRef.errorMessage
                        return .failure(Error.sqliteError(code: resultCode, text: errorString))
                    }
                }while resultCode != self.apiProvider.SQLITE_DONE
                return .success(res)
            case .failure(let error):
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    private func minInternal<T, R>(_ columnKeyPath: PartialKeyPath<T>,
                                   _ constraints: [SelectConstraint]) -> Result<R?, Error> where R: ConstructableFromSQLiteValue {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            return .failure(Error.typeIsNotMapped)
        }
        let table = anyTable as! Table<T>
        guard let column = table.columnBy(keyPath: columnKeyPath) else {
            return .failure(Error.columnNotFound)
        }
        var sql = "SELECT MIN(\"\(column.name)\") FROM \(table.name)"
        for constraint in constraints {
            switch constraint.serialize(with: .init(schemaProvider: self)) {
            case .success(let constraintsString):
                sql += " \(constraintsString)"
            case .failure(let error):
                return .failure(error)
            }
        }
        switch self.connection.createConnectionRef() {
        case .success(let connectionRef):
            switch connectionRef.prepare(sql: sql) {
            case .success(let statement):
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
                        return .failure(Error.sqliteError(code: resultCode, text: errorString))
                    }
                }while resultCode != self.apiProvider.SQLITE_DONE
                return .success(res)
            case .failure(let error):
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func min<T, F>(_ columnKeyPath: KeyPath<T, F?>,
                   _ constraints: [SelectConstraint]) -> Result<F?, Error> where F: ConstructableFromSQLiteValue {
        return self.minInternal(columnKeyPath, constraints)
    }
    
    func min<T, F>(_ columnKeyPath: KeyPath<T, F>,
                   _ constraints: [SelectConstraint]) -> Result<F?, Error> where F: ConstructableFromSQLiteValue {
        return self.minInternal(columnKeyPath, constraints)
    }
    
    private func maxInternal<T, R>(_ columnKeyPath: PartialKeyPath<T>,
                                   _ constraints: [SelectConstraint]) -> Result<R?, Error> where R: ConstructableFromSQLiteValue {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            return .failure(Error.typeIsNotMapped)
        }
        let table = anyTable as! Table<T>
        guard let column = table.columnBy(keyPath: columnKeyPath) else {
            return .failure(Error.columnNotFound)
        }
        var sql = "SELECT MAX(\"\(column.name)\") FROM \(table.name)"
        for constraint in constraints {
            switch constraint.serialize(with: .init(schemaProvider: self)) {
            case .success(let constraintsString):
                sql += " \(constraintsString)"
            case .failure(let error):
                return .failure(error)
            }
        }
        switch self.connection.createConnectionRef() {
        case .success(let connectionRef):
            switch connectionRef.prepare(sql: sql) {
            case .success(let statement):
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
                        return .failure(Error.sqliteError(code: resultCode, text: errorString))
                    }
                }while resultCode != self.apiProvider.SQLITE_DONE
                return .success(res)
            case .failure(let error):
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func max<T, F>(_ columnKeyPath: KeyPath<T, F?>,
                   _ constraints: [SelectConstraint]) -> Result<F?, Error> where F: ConstructableFromSQLiteValue {
        return self.maxInternal(columnKeyPath, constraints)
    }
    
    func max<T, F>(_ columnKeyPath: KeyPath<T, F>,
                   _ constraints: [SelectConstraint]) -> Result<F?, Error> where F: ConstructableFromSQLiteValue {
        return self.maxInternal(columnKeyPath, constraints)
    }
    
    private func groupConcatInternal<T, F>(_ columnKeyPath: KeyPath<T, F>,
                                           separator: String?,
                                           constraints: [SelectConstraint]) -> Result<String?, Error> {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            return .failure(Error.typeIsNotMapped)
        }
        let table = anyTable as! Table<T>
        guard let column = table.columnBy(keyPath: columnKeyPath) else {
            return .failure(Error.columnNotFound)
        }
        var sql = ""
        if nil == separator {
            sql = "SELECT GROUP_CONCAT(\"\(column.name)\") FROM \(table.name)"
        } else {
            sql = "SELECT GROUP_CONCAT(\"\(column.name)\", '\(separator!)') FROM \(table.name)"
        }
        for constraint in constraints {
            switch constraint.serialize(with: .init(schemaProvider: self)) {
            case .success(let constraintsString):
                sql += " \(constraintsString)"
            case .failure(let error):
                return .failure(error)
            }
        }
        switch self.connection.createConnectionRef() {
        case .success(let connectionRef):
            switch connectionRef.prepare(sql: sql) {
            case .success(let statement):
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
                        return .failure(Error.sqliteError(code: resultCode, text: errorString))
                    }
                }while resultCode != self.apiProvider.SQLITE_DONE
                return .success(res)
            case .failure(let error):
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func groupConcat<T, F>(_ columnKeyPath: KeyPath<T, F>,
                           separator: String,
                           _ constraints: [SelectConstraint]) -> Result<String?, Error> {
        return self.groupConcatInternal(columnKeyPath, separator: separator, constraints: constraints)
    }

    func groupConcat<T, F>(_ columnKeyPath: KeyPath<T, F>,
                           _ constraints: [SelectConstraint]) -> Result<String?, Error> {
        return self.groupConcatInternal(columnKeyPath, separator: nil, constraints: constraints)
    }
    
    func count<T, F>(_ columnKeyPath: KeyPath<T, F>, _ constraints: [SelectConstraint]) -> Result<Int, Error> {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            return .failure(Error.typeIsNotMapped)
        }
        let table = anyTable as! Table<T>
        guard let column = table.columnBy(keyPath: columnKeyPath) else {
            return .failure(Error.columnNotFound)
        }
        var sql = "SELECT COUNT(\"\(column.name)\") FROM \(table.name)"
        for constraint in constraints {
            switch constraint.serialize(with: .init(schemaProvider: self)) {
            case .success(let constraintsString):
                sql += " \(constraintsString)"
            case .failure(let error):
                return .failure(error)
            }
        }
        switch self.connection.createConnectionRef() {
        case .success(let connectionRef):
            switch connectionRef.prepare(sql: sql) {
            case .success(let statement):
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
                        return .failure(Error.sqliteError(code: resultCode, text: errorString))
                    }
                }while resultCode != self.apiProvider.SQLITE_DONE
                return .success(res)
            case .failure(let error):
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func count<T>(all of: T.Type, _ constraints: [SelectConstraint]) -> Result<Int, Error> {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            return .failure(Error.typeIsNotMapped)
        }
        let table = anyTable as! Table<T>
        var sql = "SELECT COUNT(*) FROM \(table.name)"
        for constraint in constraints {
            switch constraint.serialize(with: .init(schemaProvider: self)) {
            case .success(let constraintsString):
                sql += " \(constraintsString)"
            case .failure(let error):
                return .failure(error)
            }
        }
        switch self.connection.createConnectionRef() {
        case .success(let connectionRef):
            switch connectionRef.prepare(sql: sql) {
            case .success(let statement):
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
                        return .failure(Error.sqliteError(code: resultCode, text: errorString))
                    }
                } while resultCode != self.apiProvider.SQLITE_DONE
                return .success(res)
            case .failure(let error):
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func avg<T, F>(_ columnKeyPath: KeyPath<T, F>, _ constraints: [SelectConstraint]) -> Result<Double?, Error> {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            return .failure(Error.typeIsNotMapped)
        }
        let table = anyTable as! Table<T>
        guard let column = table.columnBy(keyPath: columnKeyPath) else {
            return .failure(Error.columnNotFound)
        }
        var sql = "SELECT AVG(\"\(column.name)\") FROM \(table.name)"
        for constraint in constraints {
            switch constraint.serialize(with: .init(schemaProvider: self)) {
            case .success(let constraintsString):
                sql += " \(constraintsString)"
            case .failure(let error):
                return .failure(error)
            }
        }
        switch self.connection.createConnectionRef() {
        case .success(let connectionRef):
            switch connectionRef.prepare(sql: sql) {
            case .success(let statement):
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
                        return .failure(Error.sqliteError(code: resultCode, text: errorString))
                    }
                }while resultCode != self.apiProvider.SQLITE_DONE
                return .success(res)
            case .failure(let error):
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    //  MARK: - CRUD
    
    func delete<T>(_ object: T) -> Result<Void, Error> {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            return .failure(Error.typeIsNotMapped)
        }
        let primaryKeyColumnNames = anyTable.primaryKeyColumnNames
        guard !primaryKeyColumnNames.isEmpty else {
            return .failure(Error.unableToDeleteObjectWithoutPrimaryKeys)
        }
        var sql = "DELETE FROM '\(anyTable.name)' WHERE"
        for (primaryKeyColumnNameIndex, primaryKeyColumnName) in primaryKeyColumnNames.enumerated() {
            sql += " \"" + primaryKeyColumnName + "\" = ?"
            if primaryKeyColumnNameIndex < primaryKeyColumnNames.count - 1 {
                sql += " AND"
            }
        }
        let connectionRefResult = self.connection.createConnectionRef()
        switch connectionRefResult {
        case .success(let connectionRef):
            let statementResult = connectionRef.prepare(sql: sql)
            switch statementResult {
            case .success(let statement):
                var bindIndex = 1
                for element in anyTable.elements {
                    switch element {
                    case .column(let column):
                        guard column.isPrimaryKey else { continue }
                        let binder = BinderImpl(columnIndex: bindIndex, columnBinder: statement)
                        let resultCodeResult = column.bind(binder: binder, object: object)
                        switch resultCodeResult {
                        case .success(let resultCode):
                            guard resultCode == self.apiProvider.SQLITE_OK else {
                                let errorString = connectionRef.errorMessage
                                return .failure(Error.sqliteError(code: resultCode, text: errorString))
                            }
                            bindIndex += 1
                        case .failure(let error):
                            return .failure(error)
                        }
                    }
                }
                let resultCode = statement.step()
                guard self.apiProvider.SQLITE_DONE == resultCode else {
                    let errorString = connectionRef.errorMessage
                    return .failure(Error.sqliteError(code: resultCode, text: errorString))
                }
                return .success(())
            case .failure(let error):
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func update<T>(_ object: T) -> Result<Void, Error> {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            return .failure(Error.typeIsNotMapped)
        }
        let primaryKeyColumnNames = anyTable.primaryKeyColumnNames
        guard !primaryKeyColumnNames.isEmpty else {
            return .failure(Error.unableToGetObjectWithoutPrimaryKeys)
        }
        var sql = "UPDATE '\(anyTable.name)' SET"
        var setColumnNames = [String]()
        for element in anyTable.elements {
            switch element {
            case .column(let column):
                if !column.isPrimaryKey {
                    setColumnNames.append(column.name)
                }
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
        let connectionRefResult = self.connection.createConnectionRef()
        switch connectionRefResult {
        case .success(let connectionRef):
            let prepareResult = connectionRef.prepare(sql: sql)
            switch prepareResult {
            case .success(let statement):
                var bindIndex = 1
                for element in anyTable.elements {
                    switch element {
                    case .column(let column):
                        guard !column.isPrimaryKey else { continue }
                        let binder = BinderImpl(columnIndex: bindIndex, columnBinder: statement)
                        let bindResult = column.bind(binder: binder, object: object)
                        switch bindResult {
                        case .success(let resultCode):
                            guard resultCode == self.apiProvider.SQLITE_OK else {
                                let errorString = connectionRef.errorMessage
                                return .failure(Error.sqliteError(code: resultCode, text: errorString))
                            }
                            bindIndex += 1
                        case .failure(let error):
                            return .failure(error)
                        }
                    }
                }
                for element in anyTable.elements {
                    switch element {
                    case .column(let column):
                        guard column.isPrimaryKey else { continue }
                        let binder = BinderImpl(columnIndex: bindIndex, columnBinder: statement)
                        let bindResult = column.bind(binder: binder, object: object)
                        switch bindResult {
                        case .success(let resultCode):
                            bindIndex += 1
                            guard resultCode == self.apiProvider.SQLITE_OK else {
                                let errorString = connectionRef.errorMessage
                                return .failure(Error.sqliteError(code: resultCode, text: errorString))
                            }
                        case .failure(let error):
                            return .failure(error)
                        }
                    }
                }
                let resultCode = statement.step()
                guard self.apiProvider.SQLITE_DONE == resultCode else {
                    let errorString = connectionRef.errorMessage
                    return .failure(Error.sqliteError(code: resultCode, text: errorString))
                }
                return .success(())
            case .failure(let error):
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func get<T>(id: [Bindable]) -> Result<T?, Error> where T: Initializable {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            return .failure(Error.typeIsNotMapped)
        }
        let primaryKeyColumnNames = anyTable.primaryKeyColumnNames
        guard !primaryKeyColumnNames.isEmpty else {
            return .failure(Error.unableToGetObjectWithoutPrimaryKeys)
        }
        var sql = "SELECT "
        let columnsCount = anyTable.enumeratedColumns().count
        for (columnIndex, column) in anyTable.enumeratedColumns() {
            sql += "\"\(column.name)\""
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
        let connectionRefResult = self.connection.createConnectionRef()
        switch connectionRefResult {
        case .success(let connectionRef):
            switch connectionRef.prepare(sql: sql) {
            case .success(let statement):
                var resultCode: Int32 = 0
                for (idIndex, idValue) in id.enumerated() {
                    let columnBinder = BinderImpl(columnIndex: idIndex + 1, columnBinder: statement)
                    resultCode = idValue.bind(to: columnBinder)
                    guard resultCode == self.apiProvider.SQLITE_OK else {
                        let errorString = connectionRef.errorMessage
                        return .failure(Error.sqliteError(code: resultCode, text: errorString))
                    }
                }
                resultCode = statement.step()
                switch resultCode {
                case self.apiProvider.SQLITE_ROW:
                    let table = anyTable as! Table<T>
                    var object = T()
                    for (columnIndex, anyColumn) in table.enumeratedColumns() {
                        let sqliteValue = statement.columnValue(columnIndex: columnIndex)
                        guard sqliteValue.isValid else {
                            return .failure(Error.valueIsNull)
                        }
                        let assignResult = anyColumn.assign(object: &object, sqliteValue: sqliteValue)
                        switch assignResult {
                        case .success():
                            continue
                        case .failure(let error):
                            return .failure(error)
                        }
                    }
                    return .success(object)
                case self.apiProvider.SQLITE_DONE:
                    return .success(nil)
                default:
                    let errorString = connectionRef.errorMessage
                    return .failure(Error.sqliteError(code: resultCode, text: errorString))
                }
            case .failure(let error):
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func insert<T>(_ object: T) -> Result<Int64, Error> {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            return .failure(Error.typeIsNotMapped)
        }
        var sql = "INSERT INTO \(anyTable.name) ("
        let nonPrimaryKeyColumnNamesCount = anyTable.nonPrimaryKeyColumnNamesCount
        anyTable.forEachNonPrimaryKeyColumn { column, columnIndex in
            sql += "\"\(column.name)\""
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
        let connectionRefResult = self.connection.createConnectionRef()
        switch connectionRefResult {
        case .success(let connectionRef):
            let prepareResult = connectionRef.prepare(sql: sql)
            switch prepareResult {
            case .success(let statement):
                let table = anyTable as! Table<T>
                let bindResult = table.bindNonPrimaryKey(columnBinder: statement, object: object, apiProvider: self.apiProvider)
                switch bindResult {
                case .success(var resultCode):
                    guard resultCode == self.apiProvider.SQLITE_OK else {
                        let errorString = connectionRef.errorMessage
                        return .failure(Error.sqliteError(code: resultCode, text: errorString))
                    }
                    resultCode = statement.step()
                    guard self.apiProvider.SQLITE_DONE == resultCode else {
                        let errorString = connectionRef.errorMessage
                        return .failure(Error.sqliteError(code: resultCode, text: errorString))
                    }
                    return .success(connectionRef.lastInsertRowid)
                case .failure(let error):
                    return .failure(error)
                }
            case .failure(let error):
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func replace<T>(_ object: T) -> Result<Void, Error> {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            return .failure(Error.typeIsNotMapped)
        }
        var sql = "REPLACE INTO \(anyTable.name) ("
        let columnsCount = anyTable.enumeratedColumns().count
        for (columnIndex, column) in anyTable.enumeratedColumns() {
            sql += "\"\(column.name)\""
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
        let connectionRefResult = self.connection.createConnectionRef()
        switch connectionRefResult {
        case .success(let connectionRef):
            let prepareResult = connectionRef.prepare(sql: sql)
            switch prepareResult {
            case .success(let statement):
                let table = anyTable as! Table<T>
                let bindResult = table.bind(columnBinder: statement, object: object, apiProvider: self.apiProvider)
                switch bindResult {
                case .success(var resultCode):
                    guard resultCode == self.apiProvider.SQLITE_OK else {
                        let errorString = connectionRef.errorMessage
                        return .failure(Error.sqliteError(code: resultCode, text: errorString))
                    }
                    resultCode = statement.step()
                    guard self.apiProvider.SQLITE_DONE == resultCode else {
                        let errorString = connectionRef.errorMessage
                        return .failure(Error.sqliteError(code: resultCode, text: errorString))
                    }
                    return .success(())
                case .failure(let error):
                    return .failure(error)
                }
            case .failure(let error):
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    //  MARK: - non-CRUD
    
    private func selectInternal(_ sql: String,
                                connectionRef: SafeConnectionRef,
                                columnsCount: Int,
                                append: (_ statement: Statement & ColumnBinder) -> ()) -> Result<Void, Error> {
        switch connectionRef.prepare(sql: sql) {
        case .success(let statement):
            var resultCode: Int32 = 0
            repeat {
                resultCode = statement.step()
                let statementColumnsCount = statement.columnCount()
                guard statementColumnsCount == columnsCount else {
                    return .failure(Error.columnsCountMismatch(statementColumnsCount: Int(statementColumnsCount),
                                                               storageColumnsCount: columnsCount))
                }
                switch resultCode {
                case self.apiProvider.SQLITE_ROW:
                    append(statement)
                case self.apiProvider.SQLITE_DONE:
                    break
                default:
                    let errorString = connectionRef.errorMessage
                    return .failure(Error.sqliteError(code: resultCode, text: errorString))
                }
            } while resultCode != self.apiProvider.SQLITE_DONE
            return .success(())
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func select<R1, R2, R3>(_ expression1: Expression,
                            _ expression2: Expression,
                            _ expression3: Expression,
                            _ constraints: [SelectConstraint]) -> Result<[(R1, R2, R3)], Error> where R1: ConstructableFromSQLiteValue, R2: ConstructableFromSQLiteValue, R3: ConstructableFromSQLiteValue {
        let serializationContext = SerializationContext(schemaProvider: self)
        switch expression1.serialize(with: serializationContext) {
        case .success(let columnText1):
            switch expression2.serialize(with: serializationContext) {
            case .success(let columnText2):
                switch expression3.serialize(with: serializationContext) {
                case .success(let columnText3):
                    var sql = "SELECT \(columnText1), \(columnText2), \(columnText3)"
                    for constraint in constraints {
                        switch constraint.serialize(with: serializationContext) {
                        case .success(let constraintsString):
                            sql += " \(constraintsString)"
                        case .failure(let error):
                            return .failure(error)
                        }
                    }
                    switch self.connection.createConnectionRef() {
                    case .success(let connectionRef):
                        var result = [(R1, R2, R3)]()
                        switch self.selectInternal(sql, connectionRef: connectionRef, columnsCount: 3, append: { statement in
                            result.append((R1(sqliteValue: statement.columnValuePointer(with: 0)),
                                           R2(sqliteValue: statement.columnValuePointer(with: 1)),
                                           R3(sqliteValue: statement.columnValuePointer(with: 2))))
                        }) {
                        case .success():
                            return .success(result)
                        case .failure(let error):
                            return .failure(error)
                        }
                    case .failure(let error):
                        return .failure(error)
                    }
                case .failure(let error):
                    return .failure(error)
                }
            case .failure(let error):
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func select<R1, R2>(_ expression1: Expression,
                        _ expression2: Expression,
                        _ constraints: [SelectConstraint]) -> Result<[(R1, R2)], Error> where R1: ConstructableFromSQLiteValue, R2: ConstructableFromSQLiteValue {
        let serializationContext = SerializationContext(schemaProvider: self)
        switch expression1.serialize(with: serializationContext) {
        case .success(let columnText1):
            switch expression2.serialize(with: serializationContext) {
            case .success(let columnText2):
                var sql = "SELECT \(columnText1), \(columnText2)"
                for constraint in constraints {
                    switch constraint.serialize(with: serializationContext) {
                    case .success(let constraintsString):
                        sql += " \(constraintsString)"
                    case .failure(let error):
                        return .failure(error)
                    }
                }
                switch self.connection.createConnectionRef() {
                case .success(let connectionRef):
                    var result = [(R1, R2)]()
                    switch self.selectInternal(sql, connectionRef: connectionRef, columnsCount: 2, append: { statement in
                        result.append((R1(sqliteValue: statement.columnValuePointer(with: 0)), R2(sqliteValue: statement.columnValuePointer(with: 1))))
                    }) {
                    case .success():
                        break
                    case .failure(let error):
                        return .failure(error)
                    }
                    return .success(result)
                case .failure(let error):
                    return .failure(error)
                }
            case .failure(let error):
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func select<R>(_ expression: Expression,
                   _ constraints: [SelectConstraint]) -> Result<[R], Error> where R: ConstructableFromSQLiteValue {
        let serializationContext = SerializationContext(schemaProvider: self)
        switch expression.serialize(with: serializationContext) {
        case .success(let columnText):
            var sql = "SELECT \(columnText)"
            for constraint in constraints {
                switch constraint.serialize(with: serializationContext) {
                case .success(let constraintsString):
                    sql += " \(constraintsString)"
                case .failure(let error):
                    return .failure(error)
                }
            }
            switch self.connection.createConnectionRef() {
            case .success(let connectionRef):
                var result = [R]()
                switch self.selectInternal(sql, connectionRef: connectionRef, columnsCount: 1, append: { statement in
                    result.append(.init(sqliteValue: statement.columnValuePointer(with: 0)))
                }) {
                case .success():
                    break
                case .failure(let error):
                    return .failure(error)
                }
                return .success(result)
            case .failure(let error):
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func update<T>(all of: T.Type, _ set: AssignList, _ constraints: [SelectConstraint]) -> Result<Void, Error> {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            return .failure(Error.typeIsNotMapped)
        }
        let serializationContext = SerializationContext(schemaProvider: self)
        switch set.serialize(with: serializationContext) {
        case .success(let setString):
            var sql = "UPDATE \(anyTable.name) \(setString)"
            for constraint in constraints {
                switch constraint.serialize(with: serializationContext) {
                case .success(let constraintsString):
                    sql += " \(constraintsString)"
                case .failure(let error):
                    return .failure(error)
                }
            }
            switch self.connection.createConnectionRef() {
            case .success(let connectionRef):
                switch connectionRef.prepare(sql: sql) {
                case .success(let statement):
                    let resultCode = statement.step()
                    guard self.apiProvider.SQLITE_DONE == resultCode else {
                        let errorString = connectionRef.errorMessage
                        return .failure(Error.sqliteError(code: resultCode, text: errorString))
                    }
                    return .success(())
                case .failure(let error):
                    return .failure(error)
                }
            case .failure(let error):
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func delete<T>(all of: T.Type, _ constraints: [SelectConstraint]) -> Result<Void, Error> {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            return .failure(Error.typeIsNotMapped)
        }
        var sql = "DELETE FROM \(anyTable.name)"
        for constraint in constraints {
            switch constraint.serialize(with: .init(schemaProvider: self)) {
            case .success(let constraintsString):
                sql += " \(constraintsString)"
            case .failure(let error):
                return .failure(error)
            }
        }
        switch self.connection.createConnectionRef() {
        case .success(let connectionRef):
            switch connectionRef.prepare(sql: sql) {
            case .success(let statement):
                let resultCode = statement.step()
                guard self.apiProvider.SQLITE_DONE == resultCode else {
                    let errorString = connectionRef.errorMessage
                    return .failure(Error.sqliteError(code: resultCode, text: errorString))
                }
                return .success(())
            case .failure(let error):
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func getAll<T>(_ constraints: [SelectConstraint]) -> Result<[T], Error> where T: Initializable {
        return self.getAllInternal(all: T.self, constraints: constraints)
    }
    
    func getAll<T>(all of: T.Type, _ constraints: [SelectConstraint]) -> Result<[T], Error> where T: Initializable {
        return self.getAllInternal(all: T.self, constraints: constraints)
    }
    
    private func getAllInternal<T>(all of: T.Type, constraints: [SelectConstraint]) -> Result<[T], Error> where T: Initializable {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            return .failure(Error.typeIsNotMapped)
        }
        var sql = "SELECT * FROM \(anyTable.name)"
        for constraint in constraints {
            switch constraint.serialize(with: .init(schemaProvider: self)) {
            case .success(let constraintsString):
                sql += " \(constraintsString)"
            case .failure(let error):
                return .failure(error)
            }
        }
        switch self.connection.createConnectionRef() {
        case .success(let connectionRef):
            switch connectionRef.prepare(sql: sql) {
            case .success(let statement):
                let table = anyTable as! Table<T>
                let tableColumnsCount = table.enumeratedColumns().count
                var result = [T]()
                var resultCode: Int32 = 0
                repeat {
                    resultCode = statement.step()
                    let columnsCount = statement.columnCount()
                    guard columnsCount == tableColumnsCount else {
                        return .failure(Error.columnsCountMismatch(statementColumnsCount: Int(columnsCount),
                                                                   storageColumnsCount: tableColumnsCount))
                    }
                    switch resultCode {
                    case self.apiProvider.SQLITE_ROW:
                        var object = T()
                        for (columnIndex, anyColumn) in table.enumeratedColumns() {
                            let columnValuePointer = statement.columnValuePointer(with: columnIndex)
                            let assignResult = anyColumn.assign(object: &object, sqliteValue: columnValuePointer)
                            switch assignResult {
                            case .success():
                                continue
                            case .failure(let error):
                                return .failure(error)
                            }
                        }
                        result.append(object)
                    case self.apiProvider.SQLITE_DONE:
                        break
                    default:
                        let errorString = connectionRef.errorMessage
                        return .failure(Error.sqliteError(code: resultCode, text: errorString))
                    }
                } while resultCode != self.apiProvider.SQLITE_DONE
                return .success(result)
            case .failure(let error):
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func forEach<T>(_ all: T.Type, _ constraints: [SelectConstraint],
                    callback: (_ object: T) -> Void) -> Result<Void, Error> where T: Initializable {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            return .failure(Error.typeIsNotMapped)
        }
        var sql = "SELECT * FROM \(anyTable.name)"
        for constraint in constraints {
            switch constraint.serialize(with: .init(schemaProvider: self)) {
            case .success(let constraintsString):
                sql += " \(constraintsString)"
            case .failure(let error):
                return .failure(error)
            }
        }
        switch self.connection.createConnectionRef() {
        case .success(let connectionRef):
            switch connectionRef.prepare(sql: sql) {
            case .success(let statement):
                let table = anyTable as! Table<T>
                let tableColumnsCount = table.enumeratedColumns().count
                var resultCode: Int32 = 0
                repeat {
                    resultCode = statement.step()
                    let columnsCount = statement.columnCount()
                    guard columnsCount == tableColumnsCount else {
                        return .failure(Error.columnsCountMismatch(statementColumnsCount: Int(columnsCount),
                                                                   storageColumnsCount: tableColumnsCount))
                    }
                    switch resultCode {
                    case self.apiProvider.SQLITE_ROW:
                        var object = T()
                        for (columnIndex, anyColumn) in table.enumeratedColumns() {
                            let columnValuePointer = statement.columnValuePointer(with: columnIndex)
                            let assignResult = anyColumn.assign(object: &object, sqliteValue: columnValuePointer)
                            switch assignResult {
                            case .success():
                                continue
                            case .failure(let error):
                                return .failure(error)
                            }
                        }
                        callback(object)
                    case self.apiProvider.SQLITE_DONE:
                        break
                    default:
                        let errorString = connectionRef.errorMessage
                        return .failure(Error.sqliteError(code: resultCode, text: errorString))
                    }
                } while resultCode != self.apiProvider.SQLITE_DONE
                return .success(())
            case .failure(let error):
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    //  MARK: - Schema
    
    func syncSchema(preserve: Bool) -> Result<[String: SyncSchemaResult], Error> {
        let connectionRefResult = self.connection.createConnectionRef()
        switch connectionRefResult {
        case .success(let connectionRef):
            var res = [String: SyncSchemaResult]()
            res.reserveCapacity(self.tables.count)
            for table in self.tables {
                let tableSyncResult = self.sync(table, connectionRef: connectionRef, preserve: preserve)
                switch tableSyncResult {
                case .success(let syncSchemaResult):
                    res[table.name] = syncSchemaResult
                case .failure(let error):
                    return .failure(error)
                }
            }
            return .success(res)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func tableExists(with name: String) -> Result<Bool, Error> {
        let connectionRefResult = self.connection.createConnectionRef()
        switch connectionRefResult {
        case .success(let connectionRef):
            return self.tableExists(with: name, connectionRef: connectionRef)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    private func tableExists(with name: String, connectionRef: SafeConnectionRef) -> Result<Bool, Error> {
        let sql = "SELECT COUNT(*) FROM sqlite_master WHERE type = 'table' AND name = '\(name)'"
        let prepareResult = connectionRef.prepare(sql: sql)
        switch prepareResult {
        case .success(let statement):
            var resultCode = Int32(0)
            var res = false
            repeat {
                resultCode = statement.step()
                switch resultCode {
                case self.apiProvider.SQLITE_ROW:
                    let intValue = statement.columnInt(index: 0)
                    res = intValue == 1
                case self.apiProvider.SQLITE_DONE:
                    break
                default:
                    let errorString = connectionRef.errorMessage
                    return .failure(Error.sqliteError(code: resultCode, text: errorString))
                }
            }while resultCode != self.apiProvider.SQLITE_DONE
            return .success(res)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    private func tableInfo(forTableWith name: String, connectionRef: SafeConnectionRef) -> Result<[TableInfo], Error> {
        let sql = "PRAGMA table_info('\(name)')"
        let prepareResult = connectionRef.prepare(sql: sql)
        switch prepareResult {
        case .success(let statement):
            var res = [TableInfo]()
            var resultCode = Int32(0)
            repeat {
                resultCode = statement.step()
                switch resultCode {
                case self.apiProvider.SQLITE_ROW:
                    var tableInfo = TableInfo()
                    tableInfo.cid = statement.columnInt(index: 0)
                    tableInfo.name = statement.columnText(index: 1)
                    tableInfo.type = statement.columnText(index: 2)
                    tableInfo.notNull = statement.columnInt(index: 3) == 1
                    tableInfo.dfltValue = statement.columnText(index: 4)
                    tableInfo.pk = statement.columnInt(index: 5)
                    res.append(tableInfo)
                case self.apiProvider.SQLITE_DONE:
                    break
                default:
                    let errorString = connectionRef.errorMessage
                    return .failure(Error.sqliteError(code: resultCode, text: errorString))
                }
            }while resultCode != self.apiProvider.SQLITE_DONE
            return .success(res)
        case .failure(let error):
            return .failure(error)
        }
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
            } else {
                columnsToAdd.append(storageColumnInfo)
            }

            storageColumnInfoIndex += 1
        }while storageColumnInfoIndex < storageTableInfo.count

        return notEqual
    }
    
    private func schemaStatus(for table: AnyTable, connectionRef: SafeConnectionRef, preserve: Bool) -> Result<SyncSchemaResult, Error> {
        var res = SyncSchemaResult.alredyInSync
        let tableExistsResult = self.tableExists(with: table.name, connectionRef: connectionRef)
        switch tableExistsResult {
        case .success(let tableExists):
            var gottaCreateTable = !tableExists
            if !gottaCreateTable {
                var storageTableInfo = table.tableInfo
                let tableInfoResult = self.tableInfo(forTableWith: table.name, connectionRef: connectionRef)
                switch tableInfoResult {
                case .success(var dbTableInfo):
                    var columnsToAdd = [TableInfo]()
                    if Self.calculateRemoveAddColumns(columnsToAdd: &columnsToAdd, storageTableInfo: &storageTableInfo, dbTableInfo: &dbTableInfo) {
                        gottaCreateTable = true
                    }
                    if !gottaCreateTable {  //  if all storage columns are equal to actual db columns but there are
                        //  excess columns at the db..
                        if dbTableInfo.count > 0 {
                            // extra table columns than storage columns
                            if !preserve {
                                gottaCreateTable = true
                            } else {
                                res = .oldColumnsRemoved
                            }
                        }
                    }
                    if gottaCreateTable {
                        res = .droppedAndRecreated
                    } else {
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
                                } else {
                                    res = .newColumnsAdded
                                }
                            } else {
                                res = .droppedAndRecreated
                            }
                        } else {
                            if res != .oldColumnsRemoved {
                                res = .alredyInSync
                            }
                        }
                    }
                case .failure(let error):
                    return .failure(error)
                }
            } else {
                res = .newTableCreated
            }
            return .success(res)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    private func create(tableWith name: String, columns: ColumnEnumerator, connectionRef: SafeConnectionRef) -> Result<Void, Error> {
        var sql = "CREATE TABLE '\(name)' ("
        let columnsCount = columns.count
        for (columnIndex, column) in columns {
            switch column.serialize(with: .init(schemaProvider: self)) {
            case .success(let columnString):
                sql += "\(columnString)"
                if columnIndex < columnsCount - 1 {
                    sql += ", "
                }
            case .failure(let error):
                return .failure(error)
            }
        }
        sql += ")"
        let execResult = connectionRef.exec(sql: sql)
        switch execResult {
        case .success():
            return .success(())
        case .failure(let error):
            return .failure(error)
        }
    }
    
    private func sync(_ table: AnyTable, connectionRef: SafeConnectionRef, preserve: Bool) -> Result<SyncSchemaResult, Error> {
        var res = SyncSchemaResult.alredyInSync
        let schemaStatusResult = self.schemaStatus(for: table, connectionRef: connectionRef, preserve: preserve)
        switch schemaStatusResult {
        case .success(let schemaStatus):
            if schemaStatus != .alredyInSync {
                if schemaStatus == .newTableCreated {
                    let createResult = self.create(tableWith: table.name, columns: table.enumeratedColumns(), connectionRef: connectionRef)
                    switch createResult {
                    case .success():
                        res = .newTableCreated
                    case .failure(let error):
                        return .failure(error)
                    }
                } else {
                    if schemaStatus == .oldColumnsRemoved || schemaStatus == .newColumnsAdded || schemaStatus == .newColumnsAddedAndOldColumnsRemoved {

                        //  get table info provided in `make_table` call..
                        var storageTableInfo = table.tableInfo

                        //  now get current table info from db using `PRAGMA table_info` query..
                        let tableInfoResult = self.tableInfo(forTableWith: table.name, connectionRef: connectionRef)
                        switch tableInfoResult {
                        case .success(var dbTableInfo):
                            //  this array will contain pointers to columns that gotta be added..
                            var columnsToAdd = [TableInfo]()

                            _ = Self.calculateRemoveAddColumns(columnsToAdd: &columnsToAdd, storageTableInfo: &storageTableInfo, dbTableInfo: &dbTableInfo)

                            if schemaStatus == .oldColumnsRemoved {

                                //  extra table columns than storage columns
                                let backupResult = self.backup(table, connectionRef: connectionRef, columnsToIgnore: [])
                                switch backupResult {
                                case .success():
                                    res = .oldColumnsRemoved
                                case .failure(let error):
                                    return .failure(error)
                                }
                            }

                            if schemaStatus == .newColumnsAdded {
                                for columnToAdd in columnsToAdd {
                                    let addResult = self.add(column: columnToAdd, table: table, connectionRef: connectionRef)
                                    switch addResult {
                                    case .success():
                                        break
                                    case .failure(let error):
                                        return .failure(error)
                                    }
                                }
                                res = .newColumnsAdded
                            }

                            if schemaStatus == .newColumnsAddedAndOldColumnsRemoved {

                                // remove extra columns
                                let backupResult = self.backup(table, connectionRef: connectionRef, columnsToIgnore: columnsToAdd)
                                switch backupResult {
                                case .success():
                                    res = .newColumnsAddedAndOldColumnsRemoved
                                case .failure(let error):
                                    return .failure(error)
                                }
                            }
                        case .failure(let error):
                            return .failure(error)
                        }
                    } else if schemaStatus == .droppedAndRecreated {
                        let dropTableResult = self.dropTableInternal(tableName: table.name, connectionRef: connectionRef)
                        switch dropTableResult {
                        case .success():
                            let createResult = self.create(tableWith: table.name,
                                                           columns: table.enumeratedColumns(),
                                                           connectionRef: connectionRef)
                            switch createResult {
                            case .success():
                                res = .droppedAndRecreated
                            case .failure(let error):
                                return .failure(error)
                            }
                        case .failure(let error):
                            return .failure(error)
                        }
                    }
                }
            }
            return .success(res)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    private func dropTableInternal(tableName: String, connectionRef: SafeConnectionRef) -> Result<Void, Error> {
        let sql = "DROP TABLE '\(tableName)'"
        return connectionRef.exec(sql: sql)
    }
    
    private func add(column tableInfo: TableInfo, table: AnyTable, connectionRef: SafeConnectionRef) -> Result<Void, Error> {
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
        return connectionRef.exec(sql: sql)
    }
    
    private func copy(table: AnyTable, name: String,
                      connectionRef: SafeConnectionRef,
                      columnsToIgnore: [TableInfo]) -> Result<Void, Error> {
        var columnNames = [String]()
        for (_, column) in table.enumeratedColumns() {   //  TODO: refactor to map and filter
            let columnName = column.name
            if !columnsToIgnore.contains(where: { $0.name == columnName }) {
                columnNames.append(columnName)
            }
        }
        let columnNamesCount = columnNames.count
        var sql = "INSERT INTO \(name) ("
        for (columnNameIndex, columnName) in columnNames.enumerated() {
            sql += "\"\(columnName)\""
            if columnNameIndex < columnNamesCount - 1 {
                sql += ", "
            }
        }
        sql += ") SELECT "
        for (columnNameIndex, columnName) in columnNames.enumerated() {
            sql += "\"\(columnName)\""
            if columnNameIndex < columnNamesCount - 1 {
                sql += ", "
            }
        }
        sql += " FROM '\(table.name)'"
        return connectionRef.exec(sql: sql)
    }
    
    private func renameTable(connectionRef: SafeConnectionRef, oldName: String, newName: String) -> Result<Void, Error> {
        let sql = "ALTER TABLE \(oldName) RENAME TO \(newName)"
        return connectionRef.exec(sql: sql)
    }
    
    private func backup(_ table: AnyTable, connectionRef: SafeConnectionRef, columnsToIgnore: [TableInfo]) -> Result<Void, Error> {

        //  here we copy source table to another with a name with '_backup' suffix, but in case table with such
        //  a name already exists we append suffix 1, then 2, etc until we find a free name..
        var backupTableName = "\(table.name)_backup"
        switch self.tableExists(with: backupTableName, connectionRef: connectionRef) {
        case .success(let tableExists):
            if tableExists {
                var suffix = 1
                repeat {
                    let anotherBackupTableName = "\(backupTableName)\(suffix)"
                    switch self.tableExists(with: anotherBackupTableName, connectionRef: connectionRef) {
                    case .success(let tableExists):
                        if tableExists == false {
                            backupTableName = anotherBackupTableName
                            break
                        }
                        suffix += 1
                    case .failure(let error):
                        return .failure(error)
                    }
                } while true
            }
            switch self.create(tableWith: backupTableName, columns: table.enumeratedColumns(), connectionRef: connectionRef) {
            case .success():
                switch self.copy(table: table, name: backupTableName,
                                 connectionRef: connectionRef,
                                 columnsToIgnore: columnsToIgnore) {
                case .success():
                    switch self.dropTableInternal(tableName: table.name, connectionRef: connectionRef) {
                    case .success():
                        switch self.renameTable(connectionRef: connectionRef, oldName: backupTableName, newName: table.name) {
                        case .success():
                            return .success(())
                        case .failure(let error):
                            return .failure(error)
                        }
                    case .failure(let error):
                        return .failure(error)
                    }
                case .failure(let error):
                    return .failure(error)
                }
            case .failure(let error):
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    //  MARK: - transactions
    
    func beginTransaction() -> Result<Void, Error> {
        let incrementResult = self.connection.increment()
        switch incrementResult {
        case .success():
            let connectionRefResult = self.connection.createConnectionRef()
            switch connectionRefResult {
            case .success(let connectionRef):
                let execResult = connectionRef.exec(sql: "BEGIN TRANSACTION")
                switch execResult {
                case .success(()):
                    return .success(())
                case .failure(let error):
                    return .failure(error)
                }
            case .failure(let error):
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func commit() -> Result<Void, Error> {
        let connectionRefResult = self.connection.createConnectionRef()
        switch connectionRefResult {
        case .success(let connectionRef):
            let execResult = connectionRef.exec(sql: "COMMIT")
            switch execResult {
            case .success():
                let decrementResult = self.connection.decrement()
                switch decrementResult {
                case .success():
                    return .success(())
                case .failure(let error):
                    return .failure(error)
                }
            case .failure(let error):
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func rollback() -> Result<Void, Error> {
        let connectionRefResult = self.connection.createConnectionRef()
        switch connectionRefResult {
        case .success(let connectionRef):
            let execResult = connectionRef.exec(sql: "ROLLBACK")
            switch execResult {
            case .success():
                let decrementResult = self.connection.decrement()
                switch decrementResult {
                case .success():
                    return .success(())
                case .failure(let error):
                    return .failure(error)
                }
            case .failure(let error):
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
}
