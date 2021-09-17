import Foundation

protocol ConnectionHolder: AnyObject {
    var dbMaybe: OpaquePointer? { get }
    var apiProvider: SQLiteApiProvider { get }
    var filename: String { get }
    
    func increment() throws
    func decrementUnsafe()
    func decrement() throws
}

class ConnectionHolderImpl: NSObject {
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
    
    func increment() throws {
        self.retainCount += 1
        if 1 == self.retainCount {
            let resultCode = self.apiProvider.sqlite3Open(self.filename.cString(using: .utf8), &self.dbMaybe)
            guard let db = self.dbMaybe else{
                throw Error.databaseIsNull
            }
            guard resultCode == self.apiProvider.SQLITE_OK else {
                let errorString: String
                if let cString = self.apiProvider.sqlite3Errmsg(db) {
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
            _ = self.apiProvider.sqlite3Close(self.dbMaybe)
        }
    }
    
    func decrement() throws {
        self.retainCount -= 1
        if 0 == self.retainCount {
            guard let db = self.dbMaybe else {
                throw Error.databaseIsNull
            }
            let resultCode = self.apiProvider.sqlite3Close(db)
            guard resultCode == self.apiProvider.SQLITE_OK else {
                let errorString: String
                if let cString = self.apiProvider.sqlite3Errmsg(db) {
                    errorString = String(cString: UnsafePointer(cString), encoding: .utf8) ?? ""
                }else{
                    errorString = ""
                }
                throw Error.sqliteError(code: resultCode, text: errorString)
            }
        }
    }
}
