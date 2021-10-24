import Foundation

public enum Order {
    case asc
    case desc
}

extension Order: Serializable {
    public func serialize(with serializationContext: SerializationContext) -> String {
        switch self {
        case .asc: return "ASC"
        case .desc: return "DESC"
        }
    }
}
