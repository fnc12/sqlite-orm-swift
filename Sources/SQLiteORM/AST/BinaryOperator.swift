import Foundation

public class BinaryOperator: Expression {
    var lhs: Expression
    var rhs: Expression
    var operatorType: BinaryOperatorType

    init(lhs: Expression, rhs: Expression, operatorType: BinaryOperatorType) {
        self.lhs = lhs
        self.rhs = rhs
        self.operatorType = operatorType
    }
}

extension BinaryOperator: Serializable {
    public func serialize(with serializationContext: SerializationContext) throws -> String {
        let leftString = try self.lhs.serialize(with: serializationContext)
        let rightString = try self.rhs.serialize(with: serializationContext)
        return "\(leftString) \(self.operatorType) \(rightString)"
    }
}

public func equal(lhs: Expression, rhs: Expression) -> BinaryOperator {
    return BinaryOperator(lhs: lhs, rhs: rhs, operatorType: .equal)
}

public func notEqual(lhs: Expression, rhs: Expression) -> BinaryOperator {
    return BinaryOperator(lhs: lhs, rhs: rhs, operatorType: .notEqual)
}

public func lesserThan(lhs: Expression, rhs: Expression) -> BinaryOperator {
    return BinaryOperator(lhs: lhs, rhs: rhs, operatorType: .lesserThan)
}

public func lesserOrEqual(lhs: Expression, rhs: Expression) -> BinaryOperator {
    return BinaryOperator(lhs: lhs, rhs: rhs, operatorType: .lesserOrEqual)
}

public func greaterThan(lhs: Expression, rhs: Expression) -> BinaryOperator {
    return BinaryOperator(lhs: lhs, rhs: rhs, operatorType: .greaterThan)
}

public func greaterOrEqual(lhs: Expression, rhs: Expression) -> BinaryOperator {
    return BinaryOperator(lhs: lhs, rhs: rhs, operatorType: .greaterOrEqual)
}

public func assign(_ lhs: Expression, _ rhs: Expression) -> BinaryOperator {
    return .init(lhs: lhs, rhs: rhs, operatorType: .assign)
}
