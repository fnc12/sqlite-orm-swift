import Foundation

public protocol Serializable {
    func serialize(with schemaProvider: SchemaProvider) throws -> String
}

extension Int: Serializable {
    public func serialize(with schemaProvider: SchemaProvider) throws -> String {
        return self.description
    }
}

extension Bool: Serializable {
    public func serialize(with schemaProvider: SchemaProvider) throws -> String {
        return self ? "1" : "0"
    }
}

extension String: Serializable {
    public func serialize(with schemaProvider: SchemaProvider) throws -> String {
        return "'\(self)'"
    }
}

extension KeyPath: Serializable {
    public func serialize(with schemaProvider: SchemaProvider) throws -> String {
        return try schemaProvider.columnNameWithTable(keyPath: self)
    }
}
