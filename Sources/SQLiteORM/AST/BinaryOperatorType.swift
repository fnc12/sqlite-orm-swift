import Foundation

enum BinaryOperatorType {
    case add
    case sub
    case mul
    case div
    case mod
    case equal
    case notEqual
    case lesserThan
    case lesserOrEqual
    case greaterThan
    case greaterOrEqual
    case assign
    case conc
    case and
    case or
    case `in`
}

extension BinaryOperatorType: CustomStringConvertible {
    var description: String {
        switch self {
        case .add: return "+"
        case .sub: return "-"
        case .mul: return "*"
        case .div: return "/"
        case .mod: return "%"
        case .equal: return "=="
        case .notEqual: return "!="
        case .lesserThan: return "<"
        case .greaterThan: return ">"
        case .lesserOrEqual: return "<="
        case .greaterOrEqual: return ">="
        case .assign: return "="
        case .conc: return "||"
        case .and: return "AND"
        case .or: return "OR"
        case .in: return "IN"
        }
    }
}
