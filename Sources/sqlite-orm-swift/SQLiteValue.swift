import Foundation

struct SQLiteValue {
    let handle: OpaquePointer!
    let apiProvider: SQLiteApiProvider
    
    var isValid: Bool {
        return self.handle != nil
    }
    
    var integer: Int {
        return Int(self.apiProvider.sqlite3ValueInt(self.handle))
    }
    
    var text: String {
        if let cStringValue = self.apiProvider.sqlite3ValueText(self.handle) {
            return String(cString: cStringValue)
        }else{
            return ""
        }
    }
}
