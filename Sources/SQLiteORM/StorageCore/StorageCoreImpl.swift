import Foundation

public class StorageCoreImpl {
    let tables: [AnyTable]
    private let inMemory: Bool
    let connection: ConnectionHolder
    let apiProvider: SQLiteApiProvider

    init(filename: String, apiProvider: SQLiteApiProvider, connection: ConnectionHolder, tables: [AnyTable]) throws {
        self.inMemory = filename.isEmpty || filename == ":memory:"
        self.tables = tables
        self.connection = connection
        self.apiProvider = apiProvider
        if self.inMemory {
            let incrementResult = self.connection.increment()
            switch incrementResult {
            case .success():
                break
            case .failure(let error):
                throw error
            }
        }
    }

    convenience init(filename: String, apiProvider: SQLiteApiProvider, tables: [AnyTable]) throws {
        try self.init(filename: filename,
                      apiProvider: apiProvider,
                      connection: ConnectionHolderImpl(filename: filename, apiProvider: apiProvider),
                      tables: tables)
    }

    convenience init(filename: String, tables: AnyTable...) throws {
        try self.init(filename: filename, apiProvider: SQLiteApiProviderImpl.shared, tables: tables)
    }

    deinit {
        if self.inMemory {
            self.connection.decrementUnsafe()
        }
    }
}
