import Foundation

extension StorageCore {
    private func selectInternal(_ sql: String,
                                connectionRef: SafeConnectionRef,
                                columnsCount: Int,
                                append: (_ statement: Statement & ColumnBinder) -> ()) -> Result<Void, Error> {
        switch connectionRef.prepare(sql: sql) {
        case .success(let statement):
            var resultCode: Int32 = 0
            repeat {
                resultCode = statement.step()
                let statementColumnsCount = statement.columnCount()
                guard statementColumnsCount == columnsCount else {
                    return .failure(Error.columnsCountMismatch(statementColumnsCount: Int(statementColumnsCount),
                                                               storageColumnsCount: columnsCount))
                }
                switch resultCode {
                case self.apiProvider.SQLITE_ROW:
                    append(statement)
                case self.apiProvider.SQLITE_DONE:
                    break
                default:
                    let errorString = connectionRef.errorMessage
                    return .failure(Error.sqliteError(code: resultCode, text: errorString))
                }
            } while resultCode != self.apiProvider.SQLITE_DONE
            return .success(())
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func select<R1, R2, R3>(_ expression1: Expression,
                            _ expression2: Expression,
                            _ expression3: Expression,
                            _ constraints: [SelectConstraint]) -> Result<[(R1, R2, R3)], Error> where R1: ConstructableFromSQLiteValue, R2: ConstructableFromSQLiteValue, R3: ConstructableFromSQLiteValue {
        let serializationContext = SerializationContext(schemaProvider: self)
        switch expression1.serialize(with: serializationContext) {
        case .success(let columnText1):
            switch expression2.serialize(with: serializationContext) {
            case .success(let columnText2):
                switch expression3.serialize(with: serializationContext) {
                case .success(let columnText3):
                    var sql = "SELECT \(columnText1), \(columnText2), \(columnText3)"
                    for constraint in constraints {
                        switch constraint.serialize(with: serializationContext) {
                        case .success(let constraintsString):
                            sql += " \(constraintsString)"
                        case .failure(let error):
                            return .failure(error)
                        }
                    }
                    switch self.connection.createConnectionRef() {
                    case .success(let connectionRef):
                        var result = [(R1, R2, R3)]()
                        switch self.selectInternal(sql, connectionRef: connectionRef, columnsCount: 3, append: { statement in
                            result.append((R1(sqliteValue: statement.columnValuePointer(with: 0)),
                                           R2(sqliteValue: statement.columnValuePointer(with: 1)),
                                           R3(sqliteValue: statement.columnValuePointer(with: 2))))
                        }) {
                        case .success():
                            return .success(result)
                        case .failure(let error):
                            return .failure(error)
                        }
                    case .failure(let error):
                        return .failure(error)
                    }
                case .failure(let error):
                    return .failure(error)
                }
            case .failure(let error):
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func select<R1, R2>(_ expression1: Expression,
                        _ expression2: Expression,
                        _ constraints: [SelectConstraint]) -> Result<[(R1, R2)], Error> where R1: ConstructableFromSQLiteValue, R2: ConstructableFromSQLiteValue {
        let serializationContext = SerializationContext(schemaProvider: self)
        switch expression1.serialize(with: serializationContext) {
        case .success(let columnText1):
            switch expression2.serialize(with: serializationContext) {
            case .success(let columnText2):
                var sql = "SELECT \(columnText1), \(columnText2)"
                for constraint in constraints {
                    switch constraint.serialize(with: serializationContext) {
                    case .success(let constraintsString):
                        sql += " \(constraintsString)"
                    case .failure(let error):
                        return .failure(error)
                    }
                }
                switch self.connection.createConnectionRef() {
                case .success(let connectionRef):
                    var result = [(R1, R2)]()
                    switch self.selectInternal(sql, connectionRef: connectionRef, columnsCount: 2, append: { statement in
                        result.append((R1(sqliteValue: statement.columnValuePointer(with: 0)), R2(sqliteValue: statement.columnValuePointer(with: 1))))
                    }) {
                    case .success():
                        break
                    case .failure(let error):
                        return .failure(error)
                    }
                    return .success(result)
                case .failure(let error):
                    return .failure(error)
                }
            case .failure(let error):
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func select<R>(_ expression: Expression,
                   _ constraints: [SelectConstraint]) -> Result<[R], Error> where R: ConstructableFromSQLiteValue {
        let serializationContext = SerializationContext(schemaProvider: self)
        switch expression.serialize(with: serializationContext) {
        case .success(let columnText):
            var sql = "SELECT \(columnText)"
            for constraint in constraints {
                switch constraint.serialize(with: serializationContext) {
                case .success(let constraintsString):
                    sql += " \(constraintsString)"
                case .failure(let error):
                    return .failure(error)
                }
            }
            switch self.connection.createConnectionRef() {
            case .success(let connectionRef):
                var result = [R]()
                switch self.selectInternal(sql, connectionRef: connectionRef, columnsCount: 1, append: { statement in
                    result.append(.init(sqliteValue: statement.columnValuePointer(with: 0)))
                }) {
                case .success():
                    break
                case .failure(let error):
                    return .failure(error)
                }
                return .success(result)
            case .failure(let error):
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func update<T>(all of: T.Type, _ set: AssignList, _ constraints: [SelectConstraint]) -> Result<Void, Error> {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            return .failure(Error.typeIsNotMapped)
        }
        let serializationContext = SerializationContext(schemaProvider: self)
        switch set.serialize(with: serializationContext) {
        case .success(let setString):
            var sql = "UPDATE \(anyTable.name) \(setString)"
            for constraint in constraints {
                switch constraint.serialize(with: serializationContext) {
                case .success(let constraintsString):
                    sql += " \(constraintsString)"
                case .failure(let error):
                    return .failure(error)
                }
            }
            switch self.connection.createConnectionRef() {
            case .success(let connectionRef):
                switch connectionRef.prepare(sql: sql) {
                case .success(let statement):
                    let resultCode = statement.step()
                    guard self.apiProvider.SQLITE_DONE == resultCode else {
                        let errorString = connectionRef.errorMessage
                        return .failure(Error.sqliteError(code: resultCode, text: errorString))
                    }
                    return .success(())
                case .failure(let error):
                    return .failure(error)
                }
            case .failure(let error):
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func delete<T>(all of: T.Type, _ constraints: [SelectConstraint]) -> Result<Void, Error> {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            return .failure(Error.typeIsNotMapped)
        }
        var sql = "DELETE FROM \(anyTable.name)"
        for constraint in constraints {
            switch constraint.serialize(with: .init(schemaProvider: self)) {
            case .success(let constraintsString):
                sql += " \(constraintsString)"
            case .failure(let error):
                return .failure(error)
            }
        }
        switch self.connection.createConnectionRef() {
        case .success(let connectionRef):
            switch connectionRef.prepare(sql: sql) {
            case .success(let statement):
                let resultCode = statement.step()
                guard self.apiProvider.SQLITE_DONE == resultCode else {
                    let errorString = connectionRef.errorMessage
                    return .failure(Error.sqliteError(code: resultCode, text: errorString))
                }
                return .success(())
            case .failure(let error):
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func getAll<T>(_ constraints: [SelectConstraint]) -> Result<[T], Error> where T: Initializable {
        return self.getAllInternal(all: T.self, constraints: constraints)
    }
    
    func getAll<T>(all of: T.Type, _ constraints: [SelectConstraint]) -> Result<[T], Error> where T: Initializable {
        return self.getAllInternal(all: T.self, constraints: constraints)
    }
    
    private func getAllInternal<T>(all of: T.Type, constraints: [SelectConstraint]) -> Result<[T], Error> where T: Initializable {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            return .failure(Error.typeIsNotMapped)
        }
        var sql = "SELECT * FROM \(anyTable.name)"
        for constraint in constraints {
            switch constraint.serialize(with: .init(schemaProvider: self)) {
            case .success(let constraintsString):
                sql += " \(constraintsString)"
            case .failure(let error):
                return .failure(error)
            }
        }
        switch self.connection.createConnectionRef() {
        case .success(let connectionRef):
            switch connectionRef.prepare(sql: sql) {
            case .success(let statement):
                let table = anyTable as! Table<T>
                var result = [T]()
                var resultCode: Int32 = 0
                repeat {
                    resultCode = statement.step()
                    let columnsCount = statement.columnCount()
                    guard columnsCount == table.columns.count else {
                        return .failure(Error.columnsCountMismatch(statementColumnsCount: Int(columnsCount),
                                                                   storageColumnsCount: table.columns.count))
                    }
                    switch resultCode {
                    case self.apiProvider.SQLITE_ROW:
                        var object = T()
                        for (columnIndex, anyColumn) in table.columns.enumerated() {
                            let columnValuePointer = statement.columnValuePointer(with: columnIndex)
                            let assignResult = anyColumn.assign(object: &object, sqliteValue: columnValuePointer)
                            switch assignResult {
                            case .success():
                                continue
                            case .failure(let error):
                                return .failure(error)
                            }
                        }
                        result.append(object)
                    case self.apiProvider.SQLITE_DONE:
                        break
                    default:
                        let errorString = connectionRef.errorMessage
                        return .failure(Error.sqliteError(code: resultCode, text: errorString))
                    }
                } while resultCode != self.apiProvider.SQLITE_DONE
                return .success(result)
            case .failure(let error):
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
}
