import Foundation

public protocol Expression: Serializable, AstIteratable {

}

extension Expression {
    func and(_ rhs: Expression) -> BinaryOperator {
        return SQLiteORM.and(self, rhs)
    }

    func or(_ rhs: Expression) -> BinaryOperator {
        return SQLiteORM.or(self, rhs)
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

extension Optional: Expression where Wrapped : Expression {
    
}
