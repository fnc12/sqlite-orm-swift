import Foundation

class ASTLike {
    var lhs: Expression
    var rhs: Expression
    
    init(lhs: Expression, rhs: Expression) {
        self.lhs = lhs
        self.rhs = rhs
    }
}

extension ASTLike: Serializable {
    func serialize(with serializationContext: SerializationContext) throws -> String {
        let leftString = try self.lhs.serialize(with: serializationContext)
        let rightString = try self.rhs.serialize(with: serializationContext)
        return "\(leftString) LIKE \(rightString)"
    }
}

extension ASTLike: Expression {
    
}

extension ASTLike: AstIteratable {
    func iterateAst(routine: (Expression) -> Void) {
        self.lhs.iterateAst(routine: routine)
        self.rhs.iterateAst(routine: routine)
    }
}
