import Foundation

public class SerializationContext {
    let schemaProvider: SchemaProvider
    let skipTableName: Bool

    init(schemaProvider: SchemaProvider) {
        self.schemaProvider = schemaProvider
        self.skipTableName = false
    }

    init(schemaProvider: SchemaProvider, skipTableName: Bool) {
        self.schemaProvider = schemaProvider
        self.skipTableName = skipTableName
    }

    func bySkippingTableName() -> SerializationContext {
        return .init(schemaProvider: self.schemaProvider, skipTableName: true)
    }

    func byIncludingTableName() -> SerializationContext {
        return .init(schemaProvider: self.schemaProvider, skipTableName: false)
    }
}
