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
        let getResult: Result<T?, Error> = self.getInternal(id: id)
        switch getResult {
        case .success(let object):
            return object
        case .failure(let error):
            throw error
        }
    }

    public func insert<T>(_ object: T) throws -> Int64 {
        let insertResult = self.insertInternal(object)
        switch insertResult {
        case .success(let code):
            return code
        case .failure(let error):
            throw error
        }
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
