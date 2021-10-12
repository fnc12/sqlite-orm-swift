import Foundation

public enum Order {
    case asc
    case desc
}

extension Order: Serializable {
    public func serialize(with schemaProvider: SchemaProvider) -> String {
        switch self {
        case .asc: return "ASC"
        case .desc: return "DESC"
        }
    }
}
