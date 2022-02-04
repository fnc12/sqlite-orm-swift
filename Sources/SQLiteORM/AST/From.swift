import Foundation

public class ASTFrom<T>: SelectConstraint {
    var type: T.Type

    init(type: T.Type) {
        self.type = type
    }
}

public func from<T>(_ type: T.Type) -> ASTFrom<T> {
    return .init(type: type)
}

extension ASTFrom: Serializable {
    public func serialize(with serializationContext: SerializationContext) throws -> String {
        let tableName = try serializationContext.schemaProvider.tableName(type: self.type)
        return "FROM \(tableName)"
    }
}

extension ASTFrom: AstIteratable {
    public func iterateAst(routine: (Expression) -> Void) {
        // ..
    }
}
