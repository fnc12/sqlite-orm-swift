import Foundation

public class ASTWhere: SelectConstraint {
    var expression: Expression

    init(expression: Expression) {
        self.expression = expression
    }
}

extension ASTWhere: Serializable {
    public func serialize(with serializationContext: SerializationContext) throws -> String {
        let expressionString = try self.expression.serialize(with: serializationContext)
        return "WHERE \(expressionString)"
    }
}

public func where_(_ expression: Expression) -> ASTWhere {
    return .init(expression: expression)
}
