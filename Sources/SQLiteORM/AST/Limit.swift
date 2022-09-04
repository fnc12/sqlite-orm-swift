import Foundation

public class ASTLimit: SelectConstraint {
    var exression: Expression
    var hasOffsetLabel = false
    var offsetExpression: Expression?

    init(exression: Expression, hasOffsetLabel: Bool, offsetExpression: Expression?) {
        self.exression = exression
        self.hasOffsetLabel = hasOffsetLabel
        self.offsetExpression = offsetExpression
    }
}

extension ASTLimit: Serializable {
    public func serialize(with serializationContext: SerializationContext) -> Result<String, Error> {
        switch self.exression.serialize(with: serializationContext) {
        case .success(let exressionString):
            if let offsetExpression = self.offsetExpression {
                switch offsetExpression.serialize(with: serializationContext) {
                case .success(let offsetExpressionString):
                    if self.hasOffsetLabel {
                        return .success("LIMIT \(exressionString) OFFSET \(offsetExpressionString)")
                    } else {
                        return .success("LIMIT \(exressionString), \(offsetExpressionString)")
                    }
                case .failure(let error):
                    return .failure(error)
                }
            } else {
                return .success("LIMIT \(exressionString)")
            }
        case .failure(let error):
            return .failure(error)
        }
    }
}

extension ASTLimit: AstIteratable {
    public func iterateAst(routine: (Expression) -> Void) {
        routine(self.exression)
        if let offsetExpression = self.offsetExpression {
            routine(offsetExpression)
        }
    }
}

public func limit(_ expression: Expression) -> ASTLimit {
    return .init(exression: expression, hasOffsetLabel: false, offsetExpression: nil)
}

public func limit(_ expression: Expression, offset offsetExpression: Expression) -> ASTLimit {
    return .init(exression: expression, hasOffsetLabel: true, offsetExpression: offsetExpression)
}

public func limit(_ expression: Expression, _ offsetExpression: Expression) -> ASTLimit {
    return .init(exression: expression, hasOffsetLabel: false, offsetExpression: offsetExpression)
}
