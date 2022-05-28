import Foundation

extension Storage {
    private func selectInternal(_ sql: String, connectionRef: ConnectionRef, columnsCount: Int, append: (_ statement: Statement & ColumnBinder) -> ()) throws {
        let statement = try connectionRef.prepare(sql: sql)
        var resultCode: Int32 = 0
        repeat {
            resultCode = statement.step()
            let statementColumnsCount = statement.columnCount()
            guard statementColumnsCount == columnsCount else {
                throw Error.columnsCountMismatch(statementColumnsCount: Int(statementColumnsCount), storageColumnsCount: columnsCount)
            }
            switch resultCode {
            case self.apiProvider.SQLITE_ROW:
                append(statement)
            case self.apiProvider.SQLITE_DONE:
                break
            default:
                let errorString = connectionRef.errorMessage
                throw Error.sqliteError(code: resultCode, text: errorString)
            }
        } while resultCode != self.apiProvider.SQLITE_DONE
    }
    
    public func select<R1, R2> (_ expression1: Expression, _ expression2: Expression, _ constraints: SelectConstraint...) throws -> [(R1, R2)] where R1: ConstructableFromSQLiteValue, R2: ConstructableFromSQLiteValue {
        let serializationContext = SerializationContext(schemaProvider: self)
        let columnText1 = try expression1.serialize(with: serializationContext)
        let columnText2 = try expression2.serialize(with: serializationContext)
        var sql = "SELECT \(columnText1), \(columnText2)"
        for constraint in constraints {
            let constraintsString = try constraint.serialize(with: serializationContext)
            sql += " \(constraintsString)"
        }
        let connectionRef = try ConnectionRef(connection: self.connection)
        var result = [(R1, R2)]()
        try self.selectInternal(sql, connectionRef: connectionRef, columnsCount: 2, append: { statement in
            result.append((R1(sqliteValue: statement.columnValuePointer(with: 0)), R2(sqliteValue: statement.columnValuePointer(with: 1))))
        })
        return result
    }

    public func select<R>(_ expression: Expression, _ constraints: SelectConstraint...) throws -> [R] where R: ConstructableFromSQLiteValue {
        let serializationContext = SerializationContext(schemaProvider: self)
        let columnText = try expression.serialize(with: serializationContext)
        var sql = "SELECT \(columnText)"
        for constraint in constraints {
            let constraintsString = try constraint.serialize(with: serializationContext)
            sql += " \(constraintsString)"
        }
        let connectionRef = try ConnectionRef(connection: self.connection)
        var result = [R]()
        try self.selectInternal(sql, connectionRef: connectionRef, columnsCount: 1, append: { statement in
            result.append(.init(sqliteValue: statement.columnValuePointer(with: 0)))
        })
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
    
    public func getAll<T>(all of: T.Type, _ constraints: SelectConstraint...) throws -> [T] where T: Initializable {
        return try self.getAllInternal(all: T.self, constraints: constraints)
    }
    
    private func getAllInternal<T>(all of: T.Type, constraints: [SelectConstraint]) throws -> [T] where T: Initializable {
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

    public func getAll<T>(_ constraints: SelectConstraint...) throws -> [T] where T: Initializable {
        return try self.getAllInternal(all: T.self, constraints: constraints)
    }
}
