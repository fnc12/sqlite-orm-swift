import Foundation

public class Where: SelectConstraint {
    var expression: Expression
    
    init(expression: Expression) {
        self.expression = expression
    }
}

extension Where: Serializable {
    public func serialize(with schemaProvider: SchemaProvider) throws -> String {
        let expressionString = try self.expression.serialize(with: schemaProvider)
        return "WHERE \(expressionString)"
    }
}

public func where_(_ expression: Expression) -> Where {
    return Where(expression: expression)
}
