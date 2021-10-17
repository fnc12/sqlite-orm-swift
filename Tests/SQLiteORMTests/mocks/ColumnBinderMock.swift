import Foundation
@testable import SQLiteORM

final class ColumnBinderMock: Mock<ColumnBinderCallType> {

}

enum ColumnBinderCallType: Equatable {
    case bindInt(value: Int, index: Int)
    case bindDouble(value: Double, index: Int)
    case bindText(value: String, index: Int)
    case bindNull(index: Int)

    static func==(lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.bindInt(let leftValue, let leftIndex), .bindInt(let rightValue, let rightIndex)):
            return leftValue == rightValue && leftIndex == rightIndex
        case (.bindDouble(let leftValue, let leftIndex), .bindDouble(let rightValue, let rightIndex)):
            return leftValue == rightValue && leftIndex == rightIndex
        case (.bindText(let leftValue, let leftIndex), .bindText(let rightValue, let rightIndex)):
            return leftValue == rightValue && leftIndex == rightIndex
        case (.bindNull(let leftIndex), .bindNull(let rightIndex)):
            return leftIndex == rightIndex
        default:
            return false
        }
    }
}

extension ColumnBinderMock: ColumnBinder {

    func bindInt(value: Int, index: Int) -> Int32 {
        let call = self.makeCall(with: .bindInt(value: value, index: index))
        self.calls.append(call)
        return 0
    }

    func bindDouble(value: Double, index: Int) -> Int32 {
        let call = self.makeCall(with: .bindDouble(value: value, index: index))
        self.calls.append(call)
        return 0
    }

    func bindText(value: String, index: Int) -> Int32 {
        let call = self.makeCall(with: .bindText(value: value, index: index))
        self.calls.append(call)
        return 0
    }

    func bindNull(index: Int) -> Int32 {
        let call = self.makeCall(with: .bindNull(index: index))
        self.calls.append(call)
        return 0
    }
}
