import Foundation

enum Ignorable<Wrapped> {
    case ignore
    case value(_ value: Wrapped)
}

extension Ignorable {
    init(_ value: Wrapped) {
        self = .value(value)
    }
}

extension Ignorable: Equatable where Wrapped: Equatable {
    static func==(lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case let(.value(leftValue), .value(rightValue)):
            return leftValue == rightValue
        default:
            return true
        }
    }
}
