import Foundation

public protocol Expression: Serializable {

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
