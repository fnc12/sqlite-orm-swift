import Foundation

public class ASTWhere: SelectConstraint {
    var expression: Expression

    init(expression: Expression) {
        self.expression = expression
    }
}

extension ASTWhere: Serializable {
    public func serialize(with serializationContext: SerializationContext) -> Result<String, Error> {
        switch self.expression.serialize(with: serializationContext) {
        case .success(let expressionString):
            return .success("WHERE \(expressionString)")
        case .failure(let error):
            return .failure(error)
        }
    }
}

extension ASTWhere: AstIteratable {
    public func iterateAst(routine: (Expression) -> Void) {
        self.expression.iterateAst(routine: routine)
    }
}

public func where_(_ expression: Expression) -> ASTWhere {
    return .init(expression: expression)
}
