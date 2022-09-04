import Foundation

public enum ConflictClause {
    case rollback
    case abort
    case fail
    case ignore
    case replace
}

extension ConflictClause: Serializable {
    public func serialize(with serializationContext: SerializationContext) -> Result<String, Error> {
        var res = "ON CONFLICT "
        switch self {
        case .rollback: res += "ROLLBACK"
        case .abort: res += "ABORT"
        case .fail: res += "FAIL"
        case .ignore: res += "IGNORE"
        case .replace: res += "REPLACE"
        }
        return .success(res)
    }
}
