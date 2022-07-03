import Foundation

extension BaseStorage {
    func deleteInternal<T>(_ object: T) -> Result<Void, Error> {
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
                for column in anyTable.columns {
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
    
    func updateInternal<T>(_ object: T) -> Result<Void, Error> {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            return .failure(Error.typeIsNotMapped)
        }
        let primaryKeyColumnNames = anyTable.primaryKeyColumnNames
        guard !primaryKeyColumnNames.isEmpty else {
            return .failure(Error.unableToGetObjectWithoutPrimaryKeys)
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
        let connectionRefResult = self.connection.createConnectionRef()
        switch connectionRefResult {
        case .success(let connectionRef):
            let prepareResult = connectionRef.prepare(sql: sql)
            switch prepareResult {
            case .success(let statement):
                var bindIndex = 1
                for column in anyTable.columns {
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
                for column in anyTable.columns {
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
                let resultCode = statement.step()
                guard apiProvider.SQLITE_DONE == resultCode else {
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
    
    func getInternal<T>(id: [Bindable]) -> Result<T?, Error> where T: Initializable {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            return .failure(Error.typeIsNotMapped)
        }
        let primaryKeyColumnNames = anyTable.primaryKeyColumnNames
        guard !primaryKeyColumnNames.isEmpty else {
            return .failure(Error.unableToGetObjectWithoutPrimaryKeys)
        }
        var sql = "SELECT "
        let columnsCount = anyTable.columns.count
        for (columnIndex, column) in anyTable.columns.enumerated() {
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
            let prepareResult = connectionRef.prepare(sql: sql)
            switch prepareResult {
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
                    for (columnIndex, anyColumn) in table.columns.enumerated() {
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
    
    func insertInternal<T>(_ object: T) -> Result<Int64, Error> {
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
                    guard resultCode == apiProvider.SQLITE_OK else {
                        let errorString = connectionRef.errorMessage
                        return .failure(Error.sqliteError(code: resultCode, text: errorString))
                    }
                    resultCode = statement.step()
                    guard apiProvider.SQLITE_DONE == resultCode else {
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
    
    func replaceInternal<T>(_ object: T) -> Result<Void, Error> {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            return .failure(Error.typeIsNotMapped)
        }
        var sql = "REPLACE INTO \(anyTable.name) ("
        let columnsCount = anyTable.columns.count
        for (columnIndex, column) in anyTable.columns.enumerated() {
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
                    guard resultCode == apiProvider.SQLITE_OK else {
                        let errorString = connectionRef.errorMessage
                        return .failure(Error.sqliteError(code: resultCode, text: errorString))
                    }
                    resultCode = statement.step()
                    guard apiProvider.SQLITE_DONE == resultCode else {
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
}
