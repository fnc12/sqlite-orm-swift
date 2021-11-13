import Foundation

public class UnaryOperator: Expression {
    var expression: Expression
    var operatorType: UnaryOperatorType

    init(operatorType: UnaryOperatorType, expression: Expression) {
        self.expression = expression
        self.operatorType = operatorType
    }
}

extension UnaryOperator: Serializable {

    public func serialize(with serializationContext: SerializationContext) throws -> String {
        return try "\(self.operatorType.description) \(self.expression.serialize(with: serializationContext))"
    }
}

public func binaryNot(expression: Expression) -> UnaryOperator {
    return .init(operatorType: .tilda, expression: expression)
}

public prefix func ~(expression: Expression) -> UnaryOperator {
    return .init(operatorType: .tilda, expression: expression)
}

public func plus(expression: Expression) -> UnaryOperator {
    return .init(operatorType: .plus, expression: expression)
}

public prefix func +(expression: Expression) -> UnaryOperator {
    return .init(operatorType: .plus, expression: expression)
}

public func minus(expression: Expression) -> UnaryOperator {
    return .init(operatorType: .minus, expression: expression)
}

public prefix func -(expression: Expression) -> UnaryOperator {
    return .init(operatorType: .minus, expression: expression)
}

public func not(expression: Expression) -> UnaryOperator {
    return .init(operatorType: .not, expression: expression)
}

public prefix func !(expression: Expression) -> UnaryOperator {
    return .init(operatorType: .not, expression: expression)
}
