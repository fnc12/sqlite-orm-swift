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

extension BinaryOperator: AstIteratable {
    public func iterateAst(routine: (Expression) -> ()) {
        self.lhs.iterateAst(routine: routine)
        self.rhs.iterateAst(routine: routine)
    }
}

public func equal(lhs: Expression, rhs: Expression) -> BinaryOperator {
    return BinaryOperator(lhs: lhs, rhs: rhs, operatorType: .equal)
}

public func ==(lhs: Expression, rhs: Expression) -> BinaryOperator {
    return BinaryOperator(lhs: lhs, rhs: rhs, operatorType: .equal)
}

public func notEqual(lhs: Expression, rhs: Expression) -> BinaryOperator {
    return BinaryOperator(lhs: lhs, rhs: rhs, operatorType: .notEqual)
}

public func !=(lhs: Expression, rhs: Expression) -> BinaryOperator {
    return BinaryOperator(lhs: lhs, rhs: rhs, operatorType: .notEqual)
}

public func lesserThan(lhs: Expression, rhs: Expression) -> BinaryOperator {
    return BinaryOperator(lhs: lhs, rhs: rhs, operatorType: .lesserThan)
}

public func <(lhs: Expression, rhs: Expression) -> BinaryOperator {
    return BinaryOperator(lhs: lhs, rhs: rhs, operatorType: .lesserThan)
}

public func lesserOrEqual(lhs: Expression, rhs: Expression) -> BinaryOperator {
    return BinaryOperator(lhs: lhs, rhs: rhs, operatorType: .lesserOrEqual)
}

public func <=(lhs: Expression, rhs: Expression) -> BinaryOperator {
    return BinaryOperator(lhs: lhs, rhs: rhs, operatorType: .lesserOrEqual)
}

public func greaterThan(lhs: Expression, rhs: Expression) -> BinaryOperator {
    return BinaryOperator(lhs: lhs, rhs: rhs, operatorType: .greaterThan)
}

public func >(lhs: Expression, rhs: Expression) -> BinaryOperator {
    return BinaryOperator(lhs: lhs, rhs: rhs, operatorType: .greaterThan)
}

public func greaterOrEqual(lhs: Expression, rhs: Expression) -> BinaryOperator {
    return BinaryOperator(lhs: lhs, rhs: rhs, operatorType: .greaterOrEqual)
}

public func >=(lhs: Expression, rhs: Expression) -> BinaryOperator {
    return BinaryOperator(lhs: lhs, rhs: rhs, operatorType: .greaterOrEqual)
}

public func assign(_ lhs: Expression, _ rhs: Expression) -> BinaryOperator {
    return .init(lhs: lhs, rhs: rhs, operatorType: .assign)
}

public func &=(_ lhs: Expression, _ rhs: Expression) -> BinaryOperator {
    return .init(lhs: lhs, rhs: rhs, operatorType: .assign)
}

public func conc(_ lhs: Expression, _ rhs: Expression) -> BinaryOperator {
    return .init(lhs: lhs, rhs: rhs, operatorType: .conc)
}

public func add(_ lhs: Expression, _ rhs: Expression) -> BinaryOperator {
    return .init(lhs: lhs, rhs: rhs, operatorType: .add)
}

public func +(_ lhs: Expression, _ rhs: Expression) -> BinaryOperator {
    return .init(lhs: lhs, rhs: rhs, operatorType: .add)
}

public func sub(_ lhs: Expression, _ rhs: Expression) -> BinaryOperator {
    return .init(lhs: lhs, rhs: rhs, operatorType: .sub)
}

public func -(_ lhs: Expression, _ rhs: Expression) -> BinaryOperator {
    return .init(lhs: lhs, rhs: rhs, operatorType: .sub)
}

public func mul(_ lhs: Expression, _ rhs: Expression) -> BinaryOperator {
    return .init(lhs: lhs, rhs: rhs, operatorType: .mul)
}

public func *(_ lhs: Expression, _ rhs: Expression) -> BinaryOperator {
    return .init(lhs: lhs, rhs: rhs, operatorType: .mul)
}

public func div(_ lhs: Expression, _ rhs: Expression) -> BinaryOperator {
    return .init(lhs: lhs, rhs: rhs, operatorType: .div)
}

public func /(_ lhs: Expression, _ rhs: Expression) -> BinaryOperator {
    return .init(lhs: lhs, rhs: rhs, operatorType: .div)
}

public func mod(_ lhs: Expression, _ rhs: Expression) -> BinaryOperator {
    return .init(lhs: lhs, rhs: rhs, operatorType: .mod)
}

public func %(_ lhs: Expression, _ rhs: Expression) -> BinaryOperator {
    return .init(lhs: lhs, rhs: rhs, operatorType: .mod)
}

public func and(_ lhs: Expression, _ rhs: Expression) -> BinaryOperator {
    return .init(lhs: lhs, rhs: rhs, operatorType: .and)
}

public func &&(_ lhs: Expression, _ rhs: Expression) -> BinaryOperator {
    return .init(lhs: lhs, rhs: rhs, operatorType: .and)
}

public func or(_ lhs: Expression, _ rhs: Expression) -> BinaryOperator {
    return .init(lhs: lhs, rhs: rhs, operatorType: .or)
}

public func ||(_ lhs: Expression, _ rhs: Expression) -> BinaryOperator {
    return .init(lhs: lhs, rhs: rhs, operatorType: .or)
}
