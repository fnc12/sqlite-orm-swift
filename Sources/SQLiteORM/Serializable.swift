import Foundation

public protocol Serializable {
    func serialize(with serializationContext: SerializationContext) throws -> String
}

extension Int: Serializable {
    public func serialize(with serializationContext: SerializationContext) throws -> String {
        return self.description
    }
}

extension Bool: Serializable {
    public func serialize(with serializationContext: SerializationContext) throws -> String {
        return self ? "1" : "0"
    }
}

extension String: Serializable {
    public func serialize(with serializationContext: SerializationContext) throws -> String {
        return "'\(self)'"
    }
}

extension KeyPath: Serializable {
    public func serialize(with serializationContext: SerializationContext) throws -> String {
        if serializationContext.skipTableName {
            return try serializationContext.schemaProvider.columnName(keyPath: self)
        } else {
            return try serializationContext.schemaProvider.columnNameWithTable(keyPath: self)
        }
    }
}
