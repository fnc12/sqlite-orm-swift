import Foundation

class SafeConnectionRef: BaseConnectionRef {
    var error: Error?
    
    init(connection: ConnectionHolder) {
        super.init(with: connection)
        let incrementResult = self.connection.increment()
        switch incrementResult {
        case .success():
            break
        case .failure(let error):
            self.error = error
        }
    }
    
    func prepare(sql: String) -> Result<Statement & ColumnBinder, Error> {
        guard let db = self.db else {
            return .failure(Error.databaseIsNull)
        }
        let apiProvider = self.connection.apiProvider
        var stmtMaybe: OpaquePointer?
        let resultCode = apiProvider.sqlite3PrepareV2(db, sql.cString(using: .utf8), -1, &stmtMaybe, nil)
        guard apiProvider.SQLITE_OK == resultCode else {
            let errorString = self.errorMessage
            return .failure(Error.sqliteError(code: resultCode, text: errorString))
        }
        guard let stmt = stmtMaybe else {
            return .failure(Error.statementIsNull)
        }
        return .success(StatementImpl(stmt: stmt, apiProvider: self.connection.apiProvider))
    }
}
