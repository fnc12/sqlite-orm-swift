import Foundation

enum UnaryOperatorType {
    case tilda
    case plus
    case minus
    case not
}

extension UnaryOperatorType: CustomStringConvertible {
    var description: String {
        switch self {
        case .tilda: return "~"
        case .plus: return "+"
        case .minus: return "-"
        case .not: return "NOT"
        }
    }
}
