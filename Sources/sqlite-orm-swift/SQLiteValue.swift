import Foundation

public protocol SQLiteValue: AnyObject {
    var isValid: Bool { get }
    var integer: Int { get }
    var double: Double { get }
    var text: String { get }
    var isNull: Bool { get }
}
