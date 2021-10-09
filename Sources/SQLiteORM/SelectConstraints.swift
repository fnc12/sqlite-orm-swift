import Foundation

public protocol SelectConstraintBuilder: AnyObject {
    
}

class WhereBuilder: SelectConstraintBuilder {
    var expression: Expression
    
    init(expression: Expression) {
        self.expression = expression
    }
}

func `where`(expression: Expression) -> WhereBuilder {
    return WhereBuilder(expression: expression)
}

enum BinaryOperatorType {
//    case add
//    case sub
//    case mul
//    case div
    case equal
    case notEqual
    case lesserThan
    case lesserOrEqual
    case greaterThan
    case greaterOrEqual
}

class BinaryOperator: Expression {
    var lhs: Expression
    var rhs: Expression
    var operatorType: BinaryOperatorType
    
    init(lhs: Expression, rhs: Expression, operatorType: BinaryOperatorType) {
        self.lhs = lhs
        self.rhs = rhs
        self.operatorType = operatorType
    }
}

func isEqual(lhs: Expression, rhs: Expression) -> BinaryOperator {
    return BinaryOperator(lhs: lhs, rhs: rhs, operatorType: .equal)
}

func isNotEqual(lhs: Expression, rhs: Expression) -> BinaryOperator {
    return BinaryOperator(lhs: lhs, rhs: rhs, operatorType: .notEqual)
}

func lesserThan(lhs: Expression, rhs: Expression) -> BinaryOperator {
    return BinaryOperator(lhs: lhs, rhs: rhs, operatorType: .lesserThan)
}

func lesserOrEqual(lhs: Expression, rhs: Expression) -> BinaryOperator {
    return BinaryOperator(lhs: lhs, rhs: rhs, operatorType: .lesserOrEqual)
}

func greaterThan(lhs: Expression, rhs: Expression) -> BinaryOperator {
    return BinaryOperator(lhs: lhs, rhs: rhs, operatorType: .greaterThan)
}

func greaterOrEqual(lhs: Expression, rhs: Expression) -> BinaryOperator {
    return BinaryOperator(lhs: lhs, rhs: rhs, operatorType: .greaterOrEqual)
}
