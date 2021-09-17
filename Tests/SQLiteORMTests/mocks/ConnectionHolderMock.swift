import Foundation
@testable import SQLiteORM

class ConnectionHolderMock: NSObject {
    var dbMaybe: OpaquePointer?
    var apiProvider: SQLiteApiProvider
    var filename: String
    
    var incrementCallsCount = 0
    var decrementCallsCount = 0
    var decrementUnsafeCallsCount = 0
    
    init(dbMaybe: OpaquePointer?, apiProvider: SQLiteApiProvider, filename: String) {
        self.dbMaybe = dbMaybe
        self.apiProvider = apiProvider
        self.filename = filename
        super.init()
    }
}

extension ConnectionHolderMock: ConnectionHolder {
    
    func increment() throws {
        self.incrementCallsCount += 1
    }
    
    func decrementUnsafe() {
        self.decrementUnsafeCallsCount += 1
    }
    
    func decrement() throws {
        self.decrementCallsCount += 1
    }
}
