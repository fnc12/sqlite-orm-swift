import Foundation

class ConnectionRef: NSObject {
    let connection: ConnectionHolder
    
    init(connection: ConnectionHolder) throws {
        self.connection = connection
        super.init()
        try self.connection.increment()
    }
    
    deinit {
        self.connection.decrementUnsafe()
    }
    
    var db: OpaquePointer? {
        return self.connection.dbMaybe
    }
    
    var lastInsertRowid: Int64 {
        return self.connection.apiProvider.sqlite3LastInsertRowid(self.db)
    }
    
    var errorMessage: String {
        guard let db = self.db else {
            return ""
        }
        guard let cString = self.connection.apiProvider.sqlite3Errmsg(db) else {
            return ""
        }
        return String(cString: UnsafePointer(cString), encoding: .utf8) ?? ""
    }
    
    func prepare(sql: String) throws -> Statement {
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
