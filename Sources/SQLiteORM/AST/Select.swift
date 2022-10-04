import Foundation

public class ASTSelect {
    let columns: [Expression]
    let constraints: [SelectConstraint]
    
    init(columns: [Expression], constraints: [SelectConstraint]) {
        self.columns = columns
        self.constraints = constraints
    }
}

extension ASTSelect: Serializable {
    public func serialize(with serializationContext: SerializationContext) -> Result<String, Error> {
        var result = "SELECT"
        for (columnIndex, column) in columns.enumerated() {
            switch column.serialize(with: serializationContext) {
            case .success(let columnString):
                if columnIndex > 0 {
                    result += ","
                }
                result += " \(columnString)"
            case .failure(let error):
                return .failure(error)
            }
        }
        for constraint in constraints {
            switch constraint.serialize(with: serializationContext) {
            case .success(let constraintString):
                result += " \(constraintString)"
            case .failure(let error):
                return .failure(error)
            }
        }
        return .success(result)
    }
}

extension ASTSelect: AstIteratable {
    public func iterateAst(routine: (Expression) -> Void) {
        for column in columns {
            routine(column)
        }
        for constraint in constraints {
            routine(constraint)
        }
    }
}

extension ASTSelect: Expression {}

public func select(_ expression: Expression, _ selectConstraints: SelectConstraint...) -> ASTSelect {
    return .init(columns: [expression], constraints: selectConstraints)
}
