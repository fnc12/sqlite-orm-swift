import Foundation

protocol ConnectionHolder: AnyObject {
    var dbMaybe: OpaquePointer? { get }
    var apiProvider: SQLiteApiProvider { get }
    var filename: String { get }
    var errorMessage: String { get }

    func increment() -> Result<Void, Error>
    func decrementUnsafe()
    func decrement() -> Result<Void, Error>
}
