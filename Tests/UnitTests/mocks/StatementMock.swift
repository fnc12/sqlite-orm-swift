import Foundation
@testable import sqlite_orm_swift

func equals(_ x : Any, _ y : Any) -> Bool {
    guard x is AnyHashable else { return false }
    guard y is AnyHashable else { return false }
    return (x as! AnyHashable) == (y as! AnyHashable)
}

class StatementMock: NSObject {
    override init() {
        super.init()
    }
    
    enum CallType: Equatable  {
        case step
        case columnCount
        case columnValue(columnIndex: Int)
        case columnText(index: Int)
        case columnInt(index: Int)
        case bindInt(value: Int, index: Int)
        case bindText(value: String, index: Int)
        case bind(value: Any, index: Int)
        case bindNull(index: Int)
        
        static func==(lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case (.step, .step):
                return true
            case (.columnCount, .columnCount):
                return true
            case (.columnText(let leftIndex), .columnText(let rightIndex)):
                return leftIndex == rightIndex
            case (.columnInt(let leftIndex), .columnInt(let rightIndex)):
                return leftIndex == rightIndex
            case (.bindInt(let leftValue, let leftIndex), .bindInt(let rightValue, let rightIndex)):
                return leftValue == rightValue && leftIndex == rightIndex
            case (.bindText(let leftValue, let leftIndex), .bindText(let rightValue, let rightIndex)):
                return leftValue == rightValue && leftIndex == rightIndex
            case (.bind(let leftValue, let leftIndex), .bind(let rightValue, let rightIndex)):
                return equals(leftValue, rightValue) && leftIndex == rightIndex
            case (.bindNull(let leftIndex), .bindNull(let rightIndex)):
                return leftIndex == rightIndex
            default:
                return false
            }
        }
    }
    
    struct Call: Equatable {
        let id: Int
        let callType: CallType
        
        static func==(lhs: Self, rhs: Self) -> Bool {
            return lhs.id == rhs.id && lhs.callType == rhs.callType
        }
    }
    
    var nextCallId = 0
    var calls = [Call]()
    
    private func makeCall(callType: CallType) -> Call {
        let res = Call(id: nextCallId, callType: callType)
        self.nextCallId += 1
        return res
    }
}

extension StatementMock: Statement {
    
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
    
    func bindInt(value: Int, index: Int) -> Int32 {
        let call = self.makeCall(callType: .bindInt(value: value, index: index))
        self.calls.append(call)
        return 0
    }
    
    func bindText(value: String, index: Int) -> Int32 {
        let call = self.makeCall(callType: .bindText(value: value, index: index))
        self.calls.append(call)
        return 0
    }
    
    func bindNull(index: Int) -> Int32 {
        let call = self.makeCall(callType: .bindNull(index: index))
        self.calls.append(call)
        return 0
    }
    
    func bind(value: Any, index: Int) throws -> Int32 {
        return 0
    }
}
