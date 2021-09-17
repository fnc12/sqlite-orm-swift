import Foundation
@testable import sqlite_orm_swift

class SQLiteValueMock: NSObject {
    var handle: OpaquePointer! = nil
    var isValid: Bool = false
    var integer: Int = 0
    var integerMaybe: Int? = nil
    var text: String = ""
    var textMaybe: String? = nil
}

extension SQLiteValueMock: SQLiteValue {
    
}
