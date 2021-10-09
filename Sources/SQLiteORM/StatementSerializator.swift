import Foundation

protocol Serializable: Any {
    func serialize() -> String
}
