import Foundation

public class SafeStorage {
    let storageCore: StorageCore
    
    static func create(filename: String, apiProvider: SQLiteApiProvider, tables: [AnyTable]) -> Result<SafeStorage, Swift.Error> {
        do {
            let safeStorage = try SafeStorage(filename: filename, apiProvider: apiProvider, tables: tables)
            return .success(safeStorage)
        } catch {
            return .failure(error)
        }
    }
    
    public static func create(filename: String, tables: AnyTable...) -> Result<SafeStorage, Swift.Error> {
        return self.create(filename: filename, apiProvider: SQLiteApiProviderImpl.shared, tables: tables)
    }
    
    convenience init(filename: String, tables: [AnyTable]) throws {
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
