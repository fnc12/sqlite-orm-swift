import Foundation

extension Storage {
    public func delete<T>(_ object: T) throws {
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
    
    public func update<T>(_ object: T) throws {
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
    
    public func insert<T>(_ object: T) throws -> Int64 {
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
    
    public func replace<T>(_ object: T) throws {
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
