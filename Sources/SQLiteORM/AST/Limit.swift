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
    public func serialize(with serializationContext: SerializationContext) throws -> String {
        if let offsetExpression = self.offsetExpression {
            if self.hasOffsetLabel {
                return "LIMIT \(try self.exression.serialize(with: serializationContext)) OFFSET \(try offsetExpression.serialize(with: serializationContext))"
            } else {
                return "LIMIT \(try self.exression.serialize(with: serializationContext)), \(try offsetExpression.serialize(with: serializationContext))"
            }
        } else {
            return "LIMIT \(try self.exression.serialize(with: serializationContext))"
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
