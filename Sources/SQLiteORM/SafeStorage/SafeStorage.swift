import Foundation

public class SafeStorage {
    let storageCore: StorageCore
    
    public convenience init(filename: String, tables: AnyTable...) throws {
        try self.init(filename: filename, apiProvider: SQLiteApiProviderImpl.shared, tables: tables)
    }
    
    convenience init(filename: String, apiProvider: SQLiteApiProvider, tables: [AnyTable]) throws {
        try self.init(filename: filename,
                      apiProvider: apiProvider,
                      connection: ConnectionHolderImpl(filename: filename, apiProvider: apiProvider),
                      tables: tables)
    }
    
    init(filename: String, apiProvider: SQLiteApiProvider, connection: ConnectionHolder, tables: [AnyTable]) throws {
        storageCore = try .init(filename: filename, apiProvider: apiProvider, connection: connection, tables: tables)
    }
}
