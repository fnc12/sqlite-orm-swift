import Foundation

public class ASTOrderBy: SelectConstraint {
    enum NullsStatus {
        case first
        case last
    }
    var expression: Expression
    private var collateName: String?
    private var order: Order?
    private var nullsStatus: NullsStatus?

    init(expression: Expression) {
        self.expression = expression
    }

    public func collate(_ name: String) -> ASTOrderBy {
        self.collateName = name
        return self 
    }

    public func asc() -> ASTOrderBy {
        self.order = .asc
        return self
    }

    public func desc() -> ASTOrderBy {
        self.order = .desc
        return self
    }

    public func nullsFirst() -> ASTOrderBy {
        self.nullsStatus = .first
        return self
    }

    public func nullsLast() -> ASTOrderBy {
        self.nullsStatus = .last
        return self
    }
}

extension ASTOrderBy: Serializable {
    public func serialize(with serializationContext: SerializationContext) -> Result<String, Error> {
        switch self.expression.serialize(with: serializationContext) {
        case .success(let expressionString):
            var result = "ORDER BY \(expressionString)"
            if let collateName = self.collateName {
                result += " COLLATE " + collateName
            }
            if let order = self.order {
                switch order.serialize(with: serializationContext) {
                case .success(let orderString):
                    result += " " + orderString
                case .failure(let error):
                    return .failure(error)
                }
            }
            if let nullsStatus = self.nullsStatus {
                result += " NULLS "
                switch nullsStatus {
                case .first:
                    result += "FIRST"
                case .last:
                    result += "LAST"
                }
            }
            return .success(result)
        case .failure(let error):
            return .failure(error)
        }
    }
}

extension ASTOrderBy: AstIteratable {
    public func iterateAst(routine: (Expression) -> Void) {
        self.expression.iterateAst(routine: routine)
    }
}

public func orderBy(_ expression: Expression) -> ASTOrderBy {
    return .init(expression: expression)
}
