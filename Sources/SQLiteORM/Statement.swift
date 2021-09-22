import Foundation

public protocol Statement: AnyObject {
    func step() -> Int32
    func columnCount() -> Int32
    func columnValue(columnIndex: Int) -> SQLiteValue
    func columnText(index: Int) -> String
    func columnInt(index: Int) -> Int
    func columnDouble(index: Int) -> Double
    func columnValuePointer(with columnIndex: Int) -> SQLiteValue
}
