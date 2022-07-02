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
}
