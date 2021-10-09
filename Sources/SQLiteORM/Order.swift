import Foundation

public enum Order {
    case asc
    case desc
}

extension Order: Serializable {
    func serialize() -> String {
        switch self {
        case .asc: return "ASC"
        case .desc: return "DESC"
        }
    }
}
