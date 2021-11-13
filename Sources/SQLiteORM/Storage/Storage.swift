import Foundation

public protocol Initializable {
    init()
}

public class Storage: NSObject {
    let tables: [AnyTable]
    private let inMemory: Bool
    let connection: ConnectionHolder
    let apiProvider: SQLiteApiProvider

    init(filename: String, apiProvider: SQLiteApiProvider, connection: ConnectionHolder, tables: [AnyTable]) throws {
        self.inMemory = filename.isEmpty || filename == ":memory:"
        self.tables = tables
        self.connection = connection
        self.apiProvider = apiProvider
        super.init()
        if self.inMemory {
            try self.connection.increment()
        }
    }

    convenience init(filename: String, apiProvider: SQLiteApiProvider, tables: [AnyTable]) throws {
        try self.init(filename: filename,
                      apiProvider: apiProvider,
                      connection: ConnectionHolderImpl(filename: filename, apiProvider: apiProvider),
                      tables: tables)
    }

    public convenience init(filename: String, tables: AnyTable...) throws {
        try self.init(filename: filename, apiProvider: SQLiteApiProviderImpl.shared, tables: tables)
    }

    deinit {
        if self.inMemory {
            self.connection.decrementUnsafe()
        }
    }

    public var filename: String {
        return self.connection.filename
    }

    public func iterate<T>(all of: T.Type, _ constraints: SelectConstraint...) -> View<T> {
        let anyTable = self.tables.first(where: { $0.type == T.self })!
        var sql = "SELECT * FROM \(anyTable.name)"
        for constraint in constraints {
            let constraintsString = try! constraint.serialize(with: .init(schemaProvider: self))
            sql += " \(constraintsString)"
        }
        let connectionRef = try! ConnectionRef(connection: self.connection)
        let statement = try! connectionRef.prepare(sql: sql)
        return .init(connectionRef: connectionRef, statement: statement, table: anyTable as! Table<T>, apiProvider: self.apiProvider)
    }
}
