import Foundation

public class ASTIn {
    let isNot: Bool
    let lhs: Expression
    let rhs: Expression
    
    init(isNot: Bool, lhs: Expression, rhs: Expression) {
        self.isNot = isNot
        self.lhs = lhs
        self.rhs = rhs
    }
}

extension Expression {
    public func `in`(_ rhs: Expression) -> ASTIn {
        return .init(isNot: false, lhs: self, rhs: rhs)
    }
    
    public func notIn(_ rhs: Expression) -> ASTIn {
        return .init(isNot: true, lhs: self, rhs: rhs)
    }
}

extension ASTIn: Serializable {
    public func serialize(with serializationContext: SerializationContext) -> Result<String, Error> {
        switch self.lhs.serialize(with: serializationContext) {
        case .success(let lhsString):
            var result = lhsString
            if self.isNot {
                result += " NOT IN"
            } else {
                result += " IN"
            }
            let needsParentheses = self.rhs is ASTSelect || self.rhs is [Any]
            if needsParentheses {
                result += " ("
            } else {
                result += " "
            }
            switch self.rhs.serialize(with: serializationContext) {
            case .success(let rhsString):
                result += rhsString
                if needsParentheses {
                    result += ")"
                }
                return .success(result)
            case .failure(let error):
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
}

extension ASTIn: AstIteratable {
    public func iterateAst(routine: (Expression) -> Void) {
        routine(self.lhs)
        routine(self.lhs)
    }
}

extension ASTIn: Expression {}
