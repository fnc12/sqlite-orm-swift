import Foundation

public protocol Initializable {
    init()
}

open class Storage: NSObject {
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
    
    public func forEach<T>(_ all: T.Type, _ constraints: SelectConstraint..., callback: (_ object: T) -> ()) throws where T: Initializable {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            throw Error.typeIsNotMapped
        }
        var sql = "SELECT * FROM \(anyTable.name)"
        for constraint in constraints {
            let constraintsString = try constraint.serialize(with: .init(schemaProvider: self))
            sql += " \(constraintsString)"
        }
        let connectionRef = try ConnectionRef(connection: self.connection)
        let statement = try connectionRef.prepare(sql: sql)
        let table = anyTable as! Table<T>
        var resultCode: Int32 = 0
        repeat {
            resultCode = statement.step()
            let columnsCount = statement.columnCount()
            guard columnsCount == table.columns.count else {
                throw Error.columnsCountMismatch(statementColumnsCount: Int(columnsCount), storageColumnsCount: table.columns.count)
            }
            switch resultCode {
            case self.apiProvider.SQLITE_ROW:
                var object = T()
                for (columnIndex, anyColumn) in table.columns.enumerated() {
                    let columnValuePointer = statement.columnValuePointer(with: columnIndex)
                    try anyColumn.assign(object: &object, sqliteValue: columnValuePointer)
                }
                callback(object)
            case self.apiProvider.SQLITE_DONE:
                break
            default:
                let errorString = connectionRef.errorMessage
                throw Error.sqliteError(code: resultCode, text: errorString)
            }
        } while resultCode != self.apiProvider.SQLITE_DONE
    }

    public func enumerated<T>(_ all: T.Type, _ constraints: SelectConstraint...) -> View<T> {
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
