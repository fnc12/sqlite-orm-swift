import Foundation

class BaseConnectionRef: NSObject {
    let connection: ConnectionHolder
    
    init(with connection: ConnectionHolder) {
        self.connection = connection
        super.init()
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
        return self.connection.errorMessage
    }
}
