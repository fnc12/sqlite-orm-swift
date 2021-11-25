import Foundation

public class ASTOrderBy: SelectConstraint {
    var expression: Expression

    init(expression: Expression) {
        self.expression = expression
    }
}

extension ASTOrderBy: Serializable {
    public func serialize(with serializationContext: SerializationContext) throws -> String {
        let expressionString = try self.expression.serialize(with: serializationContext)
        return "ORDER BY \(expressionString)"
    }
}

extension ASTOrderBy: AstIteratable {
    public func iterateAst(routine: (Expression) -> ()) {
        self.expression.iterateAst(routine: routine)
    }
}

public func orderBy(_ expression: Expression) -> ASTOrderBy {
    return .init(expression: expression)
}
