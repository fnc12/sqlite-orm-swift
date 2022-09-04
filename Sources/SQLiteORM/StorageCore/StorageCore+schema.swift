import Foundation

extension StorageCore {
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
    
    private func create(tableWith name: String, columns: [AnyColumn], connectionRef: SafeConnectionRef) -> Result<Void, Error> {
        var sql = "CREATE TABLE '\(name)' ("
        let columnsCount = columns.count
        for (columnIndex, column) in columns.enumerated() {
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
                    let createResult = self.create(tableWith: table.name, columns: table.columns, connectionRef: connectionRef)
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
                                                           columns: table.columns,
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
        for column in table.columns {   //  TODO: refactor to map and filter
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
            switch self.create(tableWith: backupTableName, columns: table.columns, connectionRef: connectionRef) {
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
}
