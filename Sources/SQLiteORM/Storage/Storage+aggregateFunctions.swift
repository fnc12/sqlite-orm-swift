import Foundation

extension Storage {
    public func total<T, R>(_ columnKeyPath: KeyPath<T, R>, _ constraints: SelectConstraint...) throws -> Double {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            throw Error.typeIsNotMapped
        }
        let table = anyTable as! Table<T>
        guard let column = table.columns.first(where: { $0.keyPath == columnKeyPath }) else {
            throw Error.columnNotFound
        }
        var sql = "SELECT TOTAL(\"\(column.name)\") FROM \(table.name)"
        for constraint in constraints {
            let constraintsString = try constraint.serialize(with: .init(schemaProvider: self))
            sql += " \(constraintsString)"
        }
        let connectionRef = try ConnectionRef(connection: self.connection)
        let statement = try connectionRef.prepare(sql: sql)
        var resultCode = Int32(0)
        var res: Double = 0
        repeat {
            resultCode = statement.step()
            switch resultCode {
            case self.apiProvider.SQLITE_ROW:
                res = statement.columnDouble(index: 0)
            case self.apiProvider.SQLITE_DONE:
                break
            default:
                let errorString = connectionRef.errorMessage
                throw Error.sqliteError(code: resultCode, text: errorString)
            }
        }while resultCode != self.apiProvider.SQLITE_DONE
        return res
    }

    public func sum<T, R>(_ columnKeyPath: KeyPath<T, R>, _ constraints: SelectConstraint...) throws -> Double? {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            throw Error.typeIsNotMapped
        }
        let table = anyTable as! Table<T>
        guard let column = table.columns.first(where: { $0.keyPath == columnKeyPath }) else {
            throw Error.columnNotFound
        }
        var sql = "SELECT SUM(\"\(column.name)\") FROM \(table.name)"
        for constraint in constraints {
            let constraintsString = try constraint.serialize(with: .init(schemaProvider: self))
            sql += " \(constraintsString)"
        }
        let connectionRef = try ConnectionRef(connection: self.connection)
        let statement = try connectionRef.prepare(sql: sql)
        var resultCode = Int32(0)
        var res: Double?
        repeat {
            resultCode = statement.step()
            switch resultCode {
            case self.apiProvider.SQLITE_ROW:
                let columnValue = statement.columnValue(columnIndex: 0)
                if !columnValue.isNull {
                    res = Double(sqliteValue: columnValue)
                }
            case self.apiProvider.SQLITE_DONE:
                break
            default:
                let errorString = connectionRef.errorMessage
                throw Error.sqliteError(code: resultCode, text: errorString)
            }
        }while resultCode != self.apiProvider.SQLITE_DONE
        return res
    }

    func minInternal<T, R>(_ columnKeyPath: PartialKeyPath<T>, constraints: [SelectConstraint]) throws -> R? where R: ConstructableFromSQLiteValue {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            throw Error.typeIsNotMapped
        }
        let table = anyTable as! Table<T>
        guard let column = table.columns.first(where: { $0.keyPath == columnKeyPath }) else {
            throw Error.columnNotFound
        }
        var sql = "SELECT MIN(\"\(column.name)\") FROM \(table.name)"
        for constraint in constraints {
            let constraintsString = try constraint.serialize(with: .init(schemaProvider: self))
            sql += " \(constraintsString)"
        }
        let connectionRef = try ConnectionRef(connection: self.connection)
        let statement = try connectionRef.prepare(sql: sql)
        var resultCode = Int32(0)
        var res: R?
        repeat {
            resultCode = statement.step()
            switch resultCode {
            case self.apiProvider.SQLITE_ROW:
                let columnValue = statement.columnValue(columnIndex: 0)
                if !columnValue.isNull {
                    res = R(sqliteValue: columnValue)
                }
            case self.apiProvider.SQLITE_DONE:
                break
            default:
                let errorString = connectionRef.errorMessage
                throw Error.sqliteError(code: resultCode, text: errorString)
            }
        }while resultCode != self.apiProvider.SQLITE_DONE
        return res
    }

    public func min<T, F>(_ columnKeyPath: KeyPath<T, F?>, _ constraints: SelectConstraint...) throws -> F? where F: ConstructableFromSQLiteValue {
        return try self.minInternal(columnKeyPath, constraints: constraints)
    }

    public func min<T, F>(_ columnKeyPath: KeyPath<T, F>, _ constraints: SelectConstraint...) throws -> F? where F: ConstructableFromSQLiteValue {
        return try self.minInternal(columnKeyPath, constraints: constraints)
    }

    func maxInternal<T, R>(_ columnKeyPath: PartialKeyPath<T>, constraints: [SelectConstraint]) throws -> R? where R: ConstructableFromSQLiteValue {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            throw Error.typeIsNotMapped
        }
        let table = anyTable as! Table<T>
        guard let column = table.columns.first(where: { $0.keyPath == columnKeyPath }) else {
            throw Error.columnNotFound
        }
        var sql = "SELECT MAX(\"\(column.name)\") FROM \(table.name)"
        for constraint in constraints {
            let constraintsString = try constraint.serialize(with: .init(schemaProvider: self))
            sql += " \(constraintsString)"
        }
        let connectionRef = try ConnectionRef(connection: self.connection)
        let statement = try connectionRef.prepare(sql: sql)
        var resultCode = Int32(0)
        var res: R?
        repeat {
            resultCode = statement.step()
            switch resultCode {
            case self.apiProvider.SQLITE_ROW:
                let columnValue = statement.columnValue(columnIndex: 0)
                if !columnValue.isNull {
                    res = R(sqliteValue: columnValue)
                }
            case self.apiProvider.SQLITE_DONE:
                break
            default:
                let errorString = connectionRef.errorMessage
                throw Error.sqliteError(code: resultCode, text: errorString)
            }
        }while resultCode != self.apiProvider.SQLITE_DONE
        return res
    }

    public func max<T, F>(_ columnKeyPath: KeyPath<T, F?>, _ constraints: SelectConstraint...) throws -> F? where F: ConstructableFromSQLiteValue {
        return try self.maxInternal(columnKeyPath, constraints: constraints)
    }

    public func max<T, F>(_ columnKeyPath: KeyPath<T, F>, _ constraints: SelectConstraint...) throws -> F? where F: ConstructableFromSQLiteValue {
        return try self.maxInternal(columnKeyPath, constraints: constraints)
    }

    func groupConcatInternal<T, F>(_ columnKeyPath: KeyPath<T, F>, separator: String?, constraints: [SelectConstraint]) throws -> String? {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            throw Error.typeIsNotMapped
        }
        let table = anyTable as! Table<T>
        guard let column = table.columns.first(where: { $0.keyPath == columnKeyPath }) else {
            throw Error.columnNotFound
        }
        var sql = ""
        if nil == separator {
            sql = "SELECT GROUP_CONCAT(\"\(column.name)\") FROM \(table.name)"
        } else {
            sql = "SELECT GROUP_CONCAT(\"\(column.name)\", '\(separator!)') FROM \(table.name)"
        }
        for constraint in constraints {
            let constraintsString = try constraint.serialize(with: .init(schemaProvider: self))
            sql += " \(constraintsString)"
        }
        let connectionRef = try ConnectionRef(connection: self.connection)
        let statement = try connectionRef.prepare(sql: sql)
        var resultCode = Int32(0)
        var res: String?
        repeat {
            resultCode = statement.step()
            switch resultCode {
            case self.apiProvider.SQLITE_ROW:
                let columnValue = statement.columnValue(columnIndex: 0)
                if !columnValue.isNull {
                    res = columnValue.text
                }
            case self.apiProvider.SQLITE_DONE:
                break
            default:
                let errorString = connectionRef.errorMessage
                throw Error.sqliteError(code: resultCode, text: errorString)
            }
        }while resultCode != self.apiProvider.SQLITE_DONE
        return res
    }

    public func groupConcat<T, F>(_ columnKeyPath: KeyPath<T, F>, separator: String, _ constraints: SelectConstraint...) throws -> String? {
        return try self.groupConcatInternal(columnKeyPath, separator: separator, constraints: constraints)
    }

    public func groupConcat<T, F>(_ columnKeyPath: KeyPath<T, F>, _ constraints: SelectConstraint...) throws -> String? {
        return try self.groupConcatInternal(columnKeyPath, separator: nil, constraints: constraints)
    }

    public func count<T, F>(_ columnKeyPath: KeyPath<T, F>, _ constraints: SelectConstraint...) throws -> Int {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            throw Error.typeIsNotMapped
        }
        let table = anyTable as! Table<T>
        guard let column = table.columns.first(where: { $0.keyPath == columnKeyPath }) else {
            throw Error.columnNotFound
        }
        var sql = "SELECT COUNT(\"\(column.name)\") FROM \(table.name)"
        for constraint in constraints {
            let constraintsString = try constraint.serialize(with: .init(schemaProvider: self))
            sql += " \(constraintsString)"
        }
        let connectionRef = try ConnectionRef(connection: self.connection)
        let statement = try connectionRef.prepare(sql: sql)
        var resultCode = Int32(0)
        var res = 0
        repeat {
            resultCode = statement.step()
            switch resultCode {
            case self.apiProvider.SQLITE_ROW:
                res = statement.columnInt(index: 0)
            case self.apiProvider.SQLITE_DONE:
                break
            default:
                let errorString = connectionRef.errorMessage
                throw Error.sqliteError(code: resultCode, text: errorString)
            }
        }while resultCode != self.apiProvider.SQLITE_DONE
        return res
    }

    public func count<T>(all of: T.Type, _ constraints: SelectConstraint...) throws -> Int {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            throw Error.typeIsNotMapped
        }
        let table = anyTable as! Table<T>
        var sql = "SELECT COUNT(*) FROM \(table.name)"
        for constraint in constraints {
            let constraintsString = try constraint.serialize(with: .init(schemaProvider: self))
            sql += " \(constraintsString)"
        }
        let connectionRef = try ConnectionRef(connection: self.connection)
        let statement = try connectionRef.prepare(sql: sql)
        var resultCode = Int32(0)
        var res = 0
        repeat {
            resultCode = statement.step()
            switch resultCode {
            case self.apiProvider.SQLITE_ROW:
                res = statement.columnInt(index: 0)
            case self.apiProvider.SQLITE_DONE:
                break
            default:
                let errorString = connectionRef.errorMessage
                throw Error.sqliteError(code: resultCode, text: errorString)
            }
        }while resultCode != self.apiProvider.SQLITE_DONE
        return res
    }

    public func avg<T, F>(_ columnKeyPath: KeyPath<T, F>, _ constraints: SelectConstraint...) throws -> Double? {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            throw Error.typeIsNotMapped
        }
        let table = anyTable as! Table<T>
        guard let column = table.columns.first(where: { $0.keyPath == columnKeyPath }) else {
            throw Error.columnNotFound
        }
        var sql = "SELECT AVG(\"\(column.name)\") FROM \(table.name)"
        for constraint in constraints {
            let constraintsString = try constraint.serialize(with: .init(schemaProvider: self))
            sql += " \(constraintsString)"
        }
        let connectionRef = try ConnectionRef(connection: self.connection)
        let statement = try connectionRef.prepare(sql: sql)
        var resultCode = Int32(0)
        var res: Double?
        repeat {
            resultCode = statement.step()
            switch resultCode {
            case self.apiProvider.SQLITE_ROW:
                let columnValue = statement.columnValue(columnIndex: 0)
                if !columnValue.isNull {
                    res = columnValue.double
                }
            case self.apiProvider.SQLITE_DONE:
                break
            default:
                let errorString = connectionRef.errorMessage
                throw Error.sqliteError(code: resultCode, text: errorString)
            }
        }while resultCode != self.apiProvider.SQLITE_DONE
        return res
    }
}
