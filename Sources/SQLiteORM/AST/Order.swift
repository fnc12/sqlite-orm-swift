import Foundation

public enum Order {
    case asc
    case desc
}

extension Order: Serializable {
    public func serialize(with serializationContext: SerializationContext) -> Result<String, Error> {
        switch self {
        case .asc: return .success("ASC")
        case .desc: return .success("DESC")
        }
    }
}
