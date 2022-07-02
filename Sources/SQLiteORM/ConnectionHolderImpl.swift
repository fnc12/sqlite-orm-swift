import Foundation

final class ConnectionHolderImpl: NSObject {
    let filename: String
    private(set) var retainCount = 0
    private(set) var dbMaybe: OpaquePointer?
    let apiProvider: SQLiteApiProvider

    init(filename: String, apiProvider: SQLiteApiProvider) {
        self.filename = filename
        self.apiProvider = apiProvider
        super.init()
    }
}

extension ConnectionHolderImpl: ConnectionHolder {

    var errorMessage: String {
        guard let db = self.dbMaybe else {
            return ""
        }
        guard let cString = self.apiProvider.sqlite3Errmsg(db) else {
            return ""
        }
        return String(cString: UnsafePointer(cString), encoding: .utf8) ?? ""
    }

    func increment() -> Result<Void, Error> {
        self.retainCount += 1
        if 1 == self.retainCount {
            let resultCode = self.apiProvider.sqlite3Open(self.filename.cString(using: .utf8), &self.dbMaybe)
            guard self.dbMaybe != nil else {
                return .failure(Error.databaseIsNull)
            }
            guard resultCode == self.apiProvider.SQLITE_OK else {
                let errorString = self.errorMessage
                return .failure(Error.sqliteError(code: resultCode, text: errorString))
            }
        }
        return .success(())
    }

    func decrementUnsafe() {
        self.retainCount -= 1
        if 0 == self.retainCount {
            _ = self.apiProvider.sqlite3Close(self.dbMaybe)
        }
    }

    func decrement() -> Result<Void, Error> {
        self.retainCount -= 1
        if 0 == self.retainCount {
            guard let db = self.dbMaybe else {
                return .failure(Error.databaseIsNull)
            }
            let resultCode = self.apiProvider.sqlite3Close(db)
            guard resultCode == self.apiProvider.SQLITE_OK else {
                let errorString = self.errorMessage
                return .failure(Error.sqliteError(code: resultCode, text: errorString))
            }
        }
        return .success(())
    }
    
    func createConnectionRef() -> Result<SafeConnectionRef, Error> {
        let connectionRef = SafeConnectionRef(connection: self)
        if let error = connectionRef.error {
            return .failure(error)
        } else {
            return .success(connectionRef)
        }
    }
}
