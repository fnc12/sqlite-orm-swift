import Foundation
@testable import SQLiteORM_Swift

final class StatementTestable: Statement {
    struct BindIntCall: Equatable {
        let value: Int
        let index: Int
        
        static func ==(lhs: Self, rhs: Self) -> Bool {
            return lhs.value == rhs.value && lhs.index == rhs.index
        }
    }
    var bindIntCalls = [BindIntCall]()
    
    override func bindInt(value: Int, index: Int) -> Int32 {
        self.bindIntCalls.append(BindIntCall(value: value, index: index))
        return super.bindInt(value: value, index: index)
    }
    
    struct BindTextCall: Equatable {
        let value: String
        let index: Int
        
        static func ==(lhs: Self, rhs: Self) -> Bool {
            return lhs.value == rhs.value && lhs.index == rhs.index
        }
    }
    var bindTextCalls = [BindTextCall]()
    
    override func bindText(value: String, index: Int) -> Int32 {
        self.bindTextCalls.append(BindTextCall(value: value, index: index))
        return super.bindText(value: value, index: index)
    }
}
