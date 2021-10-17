import Foundation
@testable import SQLiteORM

func equals(_ x: Any, _ y: Any) -> Bool {
    guard x is AnyHashable else { return false }
    guard y is AnyHashable else { return false }
    return (x as! AnyHashable) == (y as! AnyHashable)
}

class StatementMock: Mock<StatementCallType> {

}

enum StatementCallType: Equatable {
    case step
    case columnCount
    case columnValue(columnIndex: Int)
    case columnText(index: Int)
    case columnInt(index: Int)
    case columnDouble(index: Int)

    static func==(lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.step, .step):
            return true
        case (.columnCount, .columnCount):
            return true
        case let (.columnText(leftIndex), .columnText(rightIndex)):
            return leftIndex == rightIndex
        case let (.columnInt(leftIndex), .columnInt(rightIndex)):
            return leftIndex == rightIndex
        case let (.columnDouble(leftIndex), .columnDouble(rightIndex)):
            return leftIndex == rightIndex
        default:
            return false
        }
    }
}

extension StatementMock: Statement {

    func columnValuePointer(with columnIndex: Int) -> SQLiteValue {
        fatalError()
    }

    func step() -> Int32 {
        return 0
    }

    func columnCount() -> Int32 {
        return 0
    }

    func columnValue(columnIndex: Int) -> SQLiteValue {
        fatalError()
    }

    func columnText(index: Int) -> String {
        return ""
    }

    func columnInt(index: Int) -> Int {
        return 0
    }

    func columnDouble(index: Int) -> Double {
        return 0
    }
}
