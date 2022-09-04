import Foundation

public protocol Initializable {
    init()
}

public class Storage {
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
        storageCore = try StorageCoreImpl(filename: filename, apiProvider: apiProvider, connection: connection, tables: tables)
    }
    
    var filename: String {
        self.storageCore.filename
    }

    public func forEach<T>(_ all: T.Type, _ constraints: SelectConstraint..., callback: (_ object: T) -> Void) throws where T: Initializable {
        switch self.storageCore.forEach(T.self, constraints, callback: callback) {
        case .success():
            return
        case .failure(let error):
            throw error
        }
    }

    /*public func enumerated<T>(_ all: T.Type, _ constraints: SelectConstraint...) -> PseudoContainer<T> {
        let anyTable = self.storageCore.tables.first(where: { $0.type == T.self })!
        var sql = "SELECT * FROM \(anyTable.name)"
        for constraint in constraints {
            switch constraint.serialize(with: .init(schemaProvider: self.storageCore)) {
            case .success(let constraintsString):
                sql += " \(constraintsString)"
            case .failure(let error):
                fatalError(error.localizedDescription)  //  TODO
            }
        }
        let connectionRef = try! ConnectionRef(connection: self.storageCore.connection)
        let statement = try! connectionRef.prepare(sql: sql)
        return .init(connectionRef: connectionRef, statement: statement, table: anyTable as! Table<T>, apiProvider: self.storageCore.apiProvider)
    }*/
}
