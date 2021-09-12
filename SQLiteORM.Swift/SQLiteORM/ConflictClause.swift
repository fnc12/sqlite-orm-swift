import Foundation

public enum ConflictClause {
    case rollback
    case abort
    case fail
    case ignore
    case replace
}
