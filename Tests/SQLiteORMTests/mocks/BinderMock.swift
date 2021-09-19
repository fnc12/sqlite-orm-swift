import Foundation
@testable import SQLiteORM

final class BinderMock: Mock<BinderCallType> {
    
}

enum BinderCallType: Equatable {
    case bindInt(value: Int)
    case bindDouble(value: Double)
    case bindText(value: String)
    case bindNull
    
    static func==(lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case let (.bindInt(leftValue), .bindInt(rightValue)):
            return leftValue == rightValue
        case let (.bindDouble(leftValue), .bindDouble(rightValue)):
            return leftValue == rightValue
        case let (.bindText(leftValue), .bindText(rightValue)):
            return leftValue == rightValue
        case (.bindNull, .bindNull):
            return true
        default:
            return false
        }
    }
}

extension BinderMock: Binder {
    
    func bindInt(value: Int) -> Int32 {
        let call = self.makeCall(with: .bindInt(value: value))
        self.calls.append(call)
        return 0
    }
    
    func bindDouble(value: Double) -> Int32 {
        let call = self.makeCall(with: .bindDouble(value: value))
        self.calls.append(call)
        return 0
    }
    
    func bindText(value: String) -> Int32 {
        let call = self.makeCall(with: .bindText(value: value))
        self.calls.append(call)
        return 0
    }
    
    func bindNull() -> Int32 {
        let call = self.makeCall(with: .bindNull)
        self.calls.append(call)
        return 0
    }
}
