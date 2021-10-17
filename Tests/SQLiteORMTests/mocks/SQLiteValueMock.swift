import Foundation
@testable import SQLiteORM

class SQLiteValueMock: NSObject {
    var handle: OpaquePointer! = nil
    var isValid: Bool = false
    var integer: Int = 0
    var double: Double = 0
    var text: String = ""
    var isNull: Bool = false
}

extension SQLiteValueMock: SQLiteValue {

}
