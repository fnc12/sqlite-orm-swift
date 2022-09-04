import Foundation

public class ASTLike {
    var lhs: Expression
    var rhs: Expression
    
    init(lhs: Expression, rhs: Expression) {
        self.lhs = lhs
        self.rhs = rhs
    }
}

extension ASTLike: Serializable {
    public func serialize(with serializationContext: SerializationContext) -> Result<String, Error> {
        switch self.lhs.serialize(with: serializationContext) {
        case .success(let leftString):
            switch self.rhs.serialize(with: serializationContext) {
            case .success(let rightString):
                return .success("\(leftString) LIKE \(rightString)")
            case .failure(let error):
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
}

extension ASTLike: Expression {
    
}

extension ASTLike: AstIteratable {
    public func iterateAst(routine: (Expression) -> Void) {
        self.lhs.iterateAst(routine: routine)
        self.rhs.iterateAst(routine: routine)
    }
}
