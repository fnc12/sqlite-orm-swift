import Foundation

enum BinaryOperatorType {
//    case add
//    case sub
//    case mul
//    case div
    case equal
    case notEqual
    case lesserThan
    case lesserOrEqual
    case greaterThan
    case greaterOrEqual
    case assign
}

extension BinaryOperatorType: CustomStringConvertible {
    var description: String {
        switch self {
        case .equal: return "=="
        case .notEqual: return "!="
        case .lesserThan: return "<"
        case .greaterThan: return ">"
        case .lesserOrEqual: return "<="
        case .greaterOrEqual: return ">="
        case .assign: return "="
        }
    }
}
