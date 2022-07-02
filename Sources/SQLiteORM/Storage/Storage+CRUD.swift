import Foundation

extension Storage {
    public func delete<T>(_ object: T) throws {
        let deleteResult = self.deleteInternal(object)
        switch deleteResult {
        case .success():
            return
        case .failure(let error):
            throw error
        }
    }

    public func update<T>(_ object: T) throws {
        let updateResult = self.updateInternal(object)
        switch updateResult {
        case .success():
            return
        case .failure(let error):
            throw error
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
                        let assignResult = anyColumn.assign(object: &object, sqliteValue: sqliteValue)
                        switch assignResult {
                        case .success():
                            continue
                        case .failure(let error):
                            throw error
                        }
                    }
                    return object
                case self.apiProvider.SQLITE_DONE:
                    return nil
                default:
                    let errorString = connectionRef.errorMessage
                    throw Error.sqliteError(code: resultCode, text: errorString)
                }
            case .failure(let error):
                throw error
            }
        case .failure(let error):
            throw error
        }
    }

    public func insert<T>(_ object: T) throws -> Int64 {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            throw Error.typeIsNotMapped
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

    public func replace<T>(_ object: T) throws {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            throw Error.typeIsNotMapped
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
