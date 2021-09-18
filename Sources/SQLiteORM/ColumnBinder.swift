import Foundation

public protocol ColumnBinder: AnyObject {
    func bindInt(value: Int, index: Int) -> Int32
    func bindDouble(value: Double, index: Int) -> Int32
    func bindText(value: String, index: Int) -> Int32
    func bindNull(index: Int) -> Int32
}
