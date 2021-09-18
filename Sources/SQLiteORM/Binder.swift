import Foundation

public protocol Binder: AnyObject {
    func bindInt(value: Int) -> Int32
    func bindDouble(value: Double) -> Int32
    func bindText(value: String) -> Int32
    func bindNull() -> Int32
}
