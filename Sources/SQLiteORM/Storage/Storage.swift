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
        storageCore = try .init(filename: filename, apiProvider: apiProvider, connection: connection, tables: tables)
    }
    
    var filename: String {
        self.storageCore.filename
    }

    public func forEach<T>(_ all: T.Type, _ constraints: SelectConstraint..., callback: (_ object: T) -> Void) throws where T: Initializable {
        guard let anyTable = self.storageCore.tables.first(where: { $0.type == T.self }) else {
            throw Error.typeIsNotMapped
        }
        var sql = "SELECT * FROM \(anyTable.name)"
        for constraint in constraints {
            switch constraint.serialize(with: .init(schemaProvider: self.storageCore)) {
            case .success(let constraintsString):
                sql += " \(constraintsString)"
            case .failure(let error):
                throw error
            }
        }
        let connectionRef = try ConnectionRef(connection: self.storageCore.connection)
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
            case self.storageCore.apiProvider.SQLITE_ROW:
                var object = T()
                for (columnIndex, anyColumn) in table.columns.enumerated() {
                    let columnValuePointer = statement.columnValuePointer(with: columnIndex)
                    let assignResult = anyColumn.assign(object: &object, sqliteValue: columnValuePointer)
                    switch assignResult {
                    case .success():
                        continue
                    case .failure(let error):
                        throw error
                    }
                }
                callback(object)
            case self.storageCore.apiProvider.SQLITE_DONE:
                break
            default:
                let errorString = connectionRef.errorMessage
                throw Error.sqliteError(code: resultCode, text: errorString)
            }
        } while resultCode != self.storageCore.apiProvider.SQLITE_DONE
    }

    public func enumerated<T>(_ all: T.Type, _ constraints: SelectConstraint...) -> PseudoContainer<T> {
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
    }
}
