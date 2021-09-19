import Foundation

struct MockCall<T> where T: Equatable {
    var id: Int
    var callType: T
}

extension MockCall: Equatable {
    static func==(lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id && lhs.callType == rhs.callType
    }
}
