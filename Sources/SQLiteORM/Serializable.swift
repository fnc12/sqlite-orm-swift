import Foundation

public protocol Serializable {
    func serialize(with serializationContext: SerializationContext) -> Result<String, Error>
}

extension Int: Serializable {
    public func serialize(with serializationContext: SerializationContext) -> Result<String, Error> {
        return .success(self.description)
    }
}

extension UInt: Serializable {
    public func serialize(with serializationContext: SerializationContext) -> Result<String, Error> {
        return .success(self.description)
    }
}

extension Int64: Serializable {
    public func serialize(with serializationContext: SerializationContext) -> Result<String, Error> {
        return .success(self.description)
    }
}

extension UInt64: Serializable {
    public func serialize(with serializationContext: SerializationContext) -> Result<String, Error> {
        return .success(self.description)
    }
}

extension Bool: Serializable {
    public func serialize(with serializationContext: SerializationContext) -> Result<String, Error> {
        return .success(self ? "1" : "0")
    }
}

extension String: Serializable {
    public func serialize(with serializationContext: SerializationContext) -> Result<String, Error> {
        return .success("'\(self)'")
    }
}

extension KeyPath: Serializable {
    public func serialize(with serializationContext: SerializationContext) -> Result<String, Error> {
        if serializationContext.skipTableName {
            switch serializationContext.schemaProvider.columnName(keyPath: self) {
            case .success(let columnName):
                return .success("\"\(columnName)\"")
            case .failure(let error):
                return .failure(error)
            }
        } else {
            return serializationContext.schemaProvider.columnNameWithTable(keyPath: self)
        }
    }
}

extension Float: Serializable {
    public func serialize(with serializationContext: SerializationContext) -> Result<String, Error> {
        return .success(self.description)
    }
}

extension Double: Serializable {
    public func serialize(with serializationContext: SerializationContext) -> Result<String, Error> {
        return .success(self.description)
    }
}

extension Optional: Serializable where Wrapped : Serializable {
    public func serialize(with serializationContext: SerializationContext) -> Result<String, Error> {
        switch self {
        case .none:
            return .success("NULL")
        case .some(let value):
            return value.serialize(with: serializationContext)
        }
    }
}

extension Array: Serializable where Element: Serializable {
    public func serialize(with serializationContext: SerializationContext) -> Result<String, Error> {
        guard !isEmpty else {
            return .failure(.arrayIsEmpty)
        }
        var result = "("
        for (elementIndex, element) in self.enumerated() {
            let elementResult = element.serialize(with: serializationContext)
            switch elementResult {
            case .success(let elementString):
                if elementIndex > 0 {
                    result += ", \(elementString)"
                } else {
                    result += elementString
                }
            case .failure(let error):
                return .failure(error)
            }
        }
        result += ")"
        return .success(result)
    }
}
