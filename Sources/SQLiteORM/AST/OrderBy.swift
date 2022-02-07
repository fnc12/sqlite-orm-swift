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

    func collate(_ name: String) -> ASTOrderBy {
        self.collateName = name
        return self
    }

    func asc() -> ASTOrderBy {
        self.order = .asc
        return self
    }

    func desc() -> ASTOrderBy {
        self.order = .desc
        return self
    }

    func nullsFirst() -> ASTOrderBy {
        self.nullsStatus = .first
        return self
    }

    func nullsLast() -> ASTOrderBy {
        self.nullsStatus = .last
        return self
    }
}

extension ASTOrderBy: Serializable {
    public func serialize(with serializationContext: SerializationContext) throws -> String {
        let expressionString = try self.expression.serialize(with: serializationContext)
        var result = "ORDER BY \(expressionString)"
        if let collateName = self.collateName {
            result += " COLLATE " + collateName
        }
        if let order = self.order {
            result += " " + order.serialize(with: serializationContext)
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
        return result
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
