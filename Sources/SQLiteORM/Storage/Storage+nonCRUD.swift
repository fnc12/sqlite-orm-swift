import Foundation

extension Storage {
    public func select<R>(_ expression: Expression, _ constraints: SelectConstraint...) throws -> [R] where R: ConstructableFromSQLiteValue {
        let serializationContext = SerializationContext(schemaProvider: self)
        let columnText = try expression.serialize(with: serializationContext)
        var sql = "SELECT \(columnText)"
        for constraint in constraints {
            let constraintsString = try constraint.serialize(with: serializationContext)
            sql += " \(constraintsString)"
        }
        let connectionRef = try ConnectionRef(connection: self.connection)
        let statement = try connectionRef.prepare(sql: sql)
        var result = [R]()
        var resultCode: Int32 = 0
        repeat {
            resultCode = statement.step()
            let columnsCount = statement.columnCount()
            guard columnsCount == 1 else {
                throw Error.columnsCountMismatch(statementColumnsCount: Int(columnsCount), storageColumnsCount: 1)
            }
            switch resultCode {
            case self.apiProvider.SQLITE_ROW:
                let columnValuePointer = statement.columnValuePointer(with: 0)
                result.append(.init(sqliteValue: columnValuePointer))
            case self.apiProvider.SQLITE_DONE:
                break
            default:
                let errorString = connectionRef.errorMessage
                throw Error.sqliteError(code: resultCode, text: errorString)
            }
        } while resultCode != self.apiProvider.SQLITE_DONE
        return result
    }

    public func update<T>(all of: T.Type, _ set: AssignList, _ constraints: SelectConstraint...) throws {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            throw Error.typeIsNotMapped
        }
        let serializationContext = SerializationContext(schemaProvider: self)
        var sql = "UPDATE \(anyTable.name) \(try set.serialize(with: serializationContext))"
        for constraint in constraints {
            let constraintsString = try constraint.serialize(with: serializationContext)
            sql += " \(constraintsString)"
        }
        let connectionRef = try ConnectionRef(connection: self.connection)
        let statement = try connectionRef.prepare(sql: sql)
        let resultCode = statement.step()
        guard apiProvider.SQLITE_DONE == resultCode else {
            let errorString = connectionRef.errorMessage
            throw Error.sqliteError(code: resultCode, text: errorString)
        }
    }

    public func delete<T>(all of: T.Type, _ constraints: SelectConstraint...) throws {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            throw Error.typeIsNotMapped
        }
        var sql = "DELETE FROM \(anyTable.name)"
        for constraint in constraints {
            let constraintsString = try constraint.serialize(with: .init(schemaProvider: self))
            sql += " \(constraintsString)"
        }
        let connectionRef = try ConnectionRef(connection: self.connection)
        let statement = try connectionRef.prepare(sql: sql)
        let resultCode = statement.step()
        guard apiProvider.SQLITE_DONE == resultCode else {
            let errorString = connectionRef.errorMessage
            throw Error.sqliteError(code: resultCode, text: errorString)
        }
    }

    public func getAll<T>(_ constraints: SelectConstraint...) throws -> [T] where T: Initializable {
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
        var result = [T]()
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
                result.append(object)
            case self.apiProvider.SQLITE_DONE:
                break
            default:
                let errorString = connectionRef.errorMessage
                throw Error.sqliteError(code: resultCode, text: errorString)
            }
        } while resultCode != self.apiProvider.SQLITE_DONE
        return result
    }
}
