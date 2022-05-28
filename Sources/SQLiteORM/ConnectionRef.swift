import Foundation

class ConnectionRef: BaseConnectionRef {

    init(connection: ConnectionHolder) throws {
        super.init(with: connection)
        let incrementResult = self.connection.increment()
        switch incrementResult {
        case .success():
            break
        case .failure(let error):
            throw error
        }
    }

    deinit {
        self.connection.decrementUnsafe()
    }

    func prepare(sql: String) throws -> Statement & ColumnBinder {
        guard let db = self.db else {
            throw Error.databaseIsNull
        }
        let apiProvider = self.connection.apiProvider
        var stmtMaybe: OpaquePointer?
        let resultCode = apiProvider.sqlite3PrepareV2(db, sql.cString(using: .utf8), -1, &stmtMaybe, nil)
        guard apiProvider.SQLITE_OK == resultCode else {
            let errorString = self.errorMessage
            throw Error.sqliteError(code: resultCode, text: errorString)
        }
        guard let stmt = stmtMaybe else {
            throw Error.statementIsNull
        }
        return StatementImpl(stmt: stmt, apiProvider: self.connection.apiProvider)
    }

    func exec(sql: String) throws {
        guard let db = self.db else {
            throw Error.databaseIsNull
        }
        guard let cString = sql.cString(using: .utf8) else {
            throw Error.failedCastingSwiftStringToCString
        }
        let apiProvider = self.connection.apiProvider
        let resultCode = apiProvider.sqlite3Exec(db, cString, nil, nil, nil)
        guard apiProvider.SQLITE_OK == resultCode else {
            let errorString = self.errorMessage
            throw Error.sqliteError(code: resultCode, text: errorString)
        }
    }
}
