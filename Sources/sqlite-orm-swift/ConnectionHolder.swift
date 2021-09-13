import Foundation

class ConnectionHolder: NSObject {
    let filename: String
    private(set) var retainCount = 0
    private(set) var dbMaybe: OpaquePointer?
    let apiProvider: SQLiteApiProvider
    
    init(filename: String, apiProvider: SQLiteApiProvider) {
        self.filename = filename
        self.apiProvider = apiProvider
        super.init()
    }
    
    func increment() throws {
        self.retainCount += 1
        if 1 == self.retainCount {
            let resultCode = apiProvider.sqlite3Open(self.filename.cString(using: .utf8), &self.dbMaybe)
            guard let db = self.dbMaybe else{
                throw Error.databaseIsNull
            }
            guard resultCode == apiProvider.SQLITE_OK else {
                let errorString: String
                if let cString = apiProvider.sqlite3Errmsg(db) {
                    errorString = String(cString: UnsafePointer(cString), encoding: .utf8) ?? ""
                }else{
                    errorString = ""
                }
                throw Error.sqliteError(code: resultCode, text: errorString)
            }
        }
    }
    
    func decrementUnsafe() {
        self.retainCount -= 1
        if 0 == self.retainCount {
            _ = apiProvider.sqlite3Close(self.dbMaybe)
        }
    }
    
    func decrement() throws {
        self.retainCount -= 1
        if 0 == self.retainCount {
            guard let db = self.dbMaybe else {
                throw Error.databaseIsNull
            }
            let resultCode = apiProvider.sqlite3Close(db)
            guard resultCode == apiProvider.SQLITE_OK else {
                let errorString: String
                if let cString = apiProvider.sqlite3Errmsg(db) {
                    errorString = String(cString: UnsafePointer(cString), encoding: .utf8) ?? ""
                }else{
                    errorString = ""
                }
                throw Error.sqliteError(code: resultCode, text: errorString)
            }
        }
    }
}
