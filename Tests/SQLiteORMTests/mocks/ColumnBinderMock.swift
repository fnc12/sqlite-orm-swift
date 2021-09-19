import Foundation
@testable import SQLiteORM

final class ColumnBinderMock: NSObject {
    
    enum CallType: Equatable {
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
    
    typealias Call = MockCall<CallType>
    
    var nextCallId = 0
    var calls = [Call]()
    
    private func makeCall(callType: CallType) -> Call {
        let res = Call(id: nextCallId, callType: callType)
        self.nextCallId += 1
        return res
    }
}

extension ColumnBinderMock: ColumnBinder {
    
    func bindInt(value: Int, index: Int) -> Int32 {
        let call = self.makeCall(callType: .bindInt(value: value, index: index))
        self.calls.append(call)
        return 0
    }
    
    func bindDouble(value: Double, index: Int) -> Int32 {
        let call = self.makeCall(callType: .bindDouble(value: value, index: index))
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
}
