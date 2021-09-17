import Foundation

final class SQLiteValueImpl: NSObject {
    let handle: OpaquePointer!
    let apiProvider: SQLiteApiProvider
    
    init(handle: OpaquePointer!, apiProvider: SQLiteApiProvider) {
        self.handle = handle
        self.apiProvider = apiProvider
        super.init()
    }
}

extension SQLiteValueImpl: SQLiteValue {
    
    var isNull: Bool {
        return self.apiProvider.sqlite3ValueType(self.handle) == self.apiProvider.SQLITE_NULL
    }
    
    var isValid: Bool {
        return self.handle != nil
    }
    
    var integer: Int {
        return Int(self.apiProvider.sqlite3ValueInt(self.handle))
    }
    
    var double: Double {
        return self.apiProvider.sqlite3ValueDouble(self.handle)
    }
    
    var text: String {
        if let cStringValue = self.apiProvider.sqlite3ValueText(self.handle) {
            return String(cString: cStringValue)
        }else{
            return ""
        }
    }
}
