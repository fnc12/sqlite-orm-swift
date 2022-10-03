import Foundation

public protocol Expression: Serializable, AstIteratable {

}

extension Expression {
    public func and(_ rhs: Expression) -> BinaryOperator {
        return SQLiteORM.and(self, rhs)
    }

    public func or(_ rhs: Expression) -> BinaryOperator {
        return SQLiteORM.or(self, rhs)
    }
    
    public func `in`(_ rhs: Expression) -> BinaryOperator {
        return .init(lhs: self, rhs: rhs, operatorType: .in)
    }
}

extension Expression {
    public func like(_ rhs: Expression) -> ASTLike {
        return .init(lhs: self, rhs: rhs)
    }
}

extension Int: Expression {

}

extension UInt: Expression {

}

extension Int64: Expression {

}

extension UInt64: Expression {

}

extension Bool: Expression {

}

extension String: Expression {

}

extension KeyPath: Expression {

}

extension Float: Expression {

}

extension Double: Expression {

}

extension Optional: Expression where Wrapped: Expression {
    
}

extension Array: Expression where Element: Expression {
    
}
