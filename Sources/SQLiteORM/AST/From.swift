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
    public func serialize(with serializationContext: SerializationContext) -> Result<String, Error> {
        switch serializationContext.schemaProvider.tableName(type: self.type) {
        case .success(let tableName):
            return .success("FROM \(tableName)")
        case .failure(let error):
            return .failure(error)
        }
    }
}

extension ASTFrom: AstIteratable {
    public func iterateAst(routine: (Expression) -> Void) {
        // ..
    }
}
