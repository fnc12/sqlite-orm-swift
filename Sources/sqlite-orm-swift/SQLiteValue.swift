import Foundation

protocol SQLiteValue: AnyObject {
    var handle: OpaquePointer! { get }
    var isValid: Bool { get }
    var integer: Int { get }
    var integerMaybe: Int? { get }
    var text: String { get }
    var textMaybe: String? { get }
}

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
    var isValid: Bool {
        return self.handle != nil
    }
    
    var integer: Int {
        return Int(self.apiProvider.sqlite3ValueInt(self.handle))
    }
    
    var integerMaybe: Int? {
        let type = self.apiProvider.sqlite3ValueType(self.handle)
        if type == self.apiProvider.SQLITE_NULL {
            return nil
        }else{
            return self.integer
        }
    }
    
    var text: String {
        if let cStringValue = self.apiProvider.sqlite3ValueText(self.handle) {
            return String(cString: cStringValue)
        }else{
            return ""
        }
    }
    
    var textMaybe: String? {
        let type = self.apiProvider.sqlite3ValueType(self.handle)
        if type == self.apiProvider.SQLITE_NULL {
            return nil
        }else{
            return self.text
        }
    }
}
