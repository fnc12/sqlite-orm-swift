import Foundation

struct SQLiteApiProviderCall {
    let id: Int
    let callType: SQLiteApiProviderCallType
}

extension SQLiteApiProviderCall: Equatable {
    static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id && lhs.callType == rhs.callType
    }
}
