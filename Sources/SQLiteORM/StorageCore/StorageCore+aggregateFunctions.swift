import Foundation

extension StorageCore {
    func total<T, R>(_ columnKeyPath: KeyPath<T, R>, _ constraints: [SelectConstraint]) -> Result<Double, Error> {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            return .failure(Error.typeIsNotMapped)
        }
        let table = anyTable as! Table<T>
        guard let column = table.columns.first(where: { $0.keyPath == columnKeyPath }) else {
            return .failure(Error.columnNotFound)
        }
        var sql = "SELECT TOTAL(\"\(column.name)\") FROM \(table.name)"
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
                        return .failure(Error.sqliteError(code: resultCode, text: errorString))
                    }
                }while resultCode != self.apiProvider.SQLITE_DONE
                return .success(res)
            case .failure(let error):
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func sum<T, R>(_ columnKeyPath: KeyPath<T, R>, _ constraints: [SelectConstraint]) -> Result<Double?, Error> {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            return .failure(Error.typeIsNotMapped)
        }
        let table = anyTable as! Table<T>
        guard let column = table.columns.first(where: { $0.keyPath == columnKeyPath }) else {
            return .failure(Error.columnNotFound)
        }
        var sql = "SELECT SUM(\"\(column.name)\") FROM \(table.name)"
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
                        return .failure(Error.sqliteError(code: resultCode, text: errorString))
                    }
                }while resultCode != self.apiProvider.SQLITE_DONE
                return .success(res)
            case .failure(let error):
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    private func minInternal<T, R>(_ columnKeyPath: PartialKeyPath<T>,
                                   _ constraints: [SelectConstraint]) -> Result<R?, Error> where R: ConstructableFromSQLiteValue {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            return .failure(Error.typeIsNotMapped)
        }
        let table = anyTable as! Table<T>
        guard let column = table.columns.first(where: { $0.keyPath == columnKeyPath }) else {
            return .failure(Error.columnNotFound)
        }
        var sql = "SELECT MIN(\"\(column.name)\") FROM \(table.name)"
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
                        return .failure(Error.sqliteError(code: resultCode, text: errorString))
                    }
                }while resultCode != self.apiProvider.SQLITE_DONE
                return .success(res)
            case .failure(let error):
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func min<T, F>(_ columnKeyPath: KeyPath<T, F?>,
                   _ constraints: [SelectConstraint]) -> Result<F?, Error> where F: ConstructableFromSQLiteValue {
        return self.minInternal(columnKeyPath, constraints)
    }
    
    func min<T, F>(_ columnKeyPath: KeyPath<T, F>,
                   _ constraints: [SelectConstraint]) -> Result<F?, Error> where F: ConstructableFromSQLiteValue {
        return self.minInternal(columnKeyPath, constraints)
    }
    
    private func maxInternal<T, R>(_ columnKeyPath: PartialKeyPath<T>,
                                   _ constraints: [SelectConstraint]) -> Result<R?, Error> where R: ConstructableFromSQLiteValue {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            return .failure(Error.typeIsNotMapped)
        }
        let table = anyTable as! Table<T>
        guard let column = table.columns.first(where: { $0.keyPath == columnKeyPath }) else {
            return .failure(Error.columnNotFound)
        }
        var sql = "SELECT MAX(\"\(column.name)\") FROM \(table.name)"
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
                        return .failure(Error.sqliteError(code: resultCode, text: errorString))
                    }
                }while resultCode != self.apiProvider.SQLITE_DONE
                return .success(res)
            case .failure(let error):
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func max<T, F>(_ columnKeyPath: KeyPath<T, F?>,
                   _ constraints: [SelectConstraint]) -> Result<F?, Error> where F: ConstructableFromSQLiteValue {
        return self.maxInternal(columnKeyPath, constraints)
    }
    
    func max<T, F>(_ columnKeyPath: KeyPath<T, F>, _ constraints: [SelectConstraint]) -> Result<F?, Error> where F: ConstructableFromSQLiteValue {
        return self.maxInternal(columnKeyPath, constraints)
    }
    
    private func groupConcatInternal<T, F>(_ columnKeyPath: KeyPath<T, F>,
                                           separator: String?,
                                           constraints: [SelectConstraint]) -> Result<String?, Error> {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            return .failure(Error.typeIsNotMapped)
        }
        let table = anyTable as! Table<T>
        guard let column = table.columns.first(where: { $0.keyPath == columnKeyPath }) else {
            return .failure(Error.columnNotFound)
        }
        var sql = ""
        if nil == separator {
            sql = "SELECT GROUP_CONCAT(\"\(column.name)\") FROM \(table.name)"
        } else {
            sql = "SELECT GROUP_CONCAT(\"\(column.name)\", '\(separator!)') FROM \(table.name)"
        }
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
                        return .failure(Error.sqliteError(code: resultCode, text: errorString))
                    }
                }while resultCode != self.apiProvider.SQLITE_DONE
                return .success(res)
            case .failure(let error):
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func groupConcat<T, F>(_ columnKeyPath: KeyPath<T, F>,
                           separator: String,
                           _ constraints: [SelectConstraint]) -> Result<String?, Error> {
        return self.groupConcatInternal(columnKeyPath, separator: separator, constraints: constraints)
    }

    func groupConcat<T, F>(_ columnKeyPath: KeyPath<T, F>,
                           _ constraints: [SelectConstraint]) -> Result<String?, Error> {
        return self.groupConcatInternal(columnKeyPath, separator: nil, constraints: constraints)
    }
    
    func count<T, F>(_ columnKeyPath: KeyPath<T, F>, _ constraints: [SelectConstraint]) -> Result<Int, Error> {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            return .failure(Error.typeIsNotMapped)
        }
        let table = anyTable as! Table<T>
        guard let column = table.columns.first(where: { $0.keyPath == columnKeyPath }) else {
            return .failure(Error.columnNotFound)
        }
        var sql = "SELECT COUNT(\"\(column.name)\") FROM \(table.name)"
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
                        return .failure(Error.sqliteError(code: resultCode, text: errorString))
                    }
                }while resultCode != self.apiProvider.SQLITE_DONE
                return .success(res)
            case .failure(let error):
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func count<T>(all of: T.Type, _ constraints: [SelectConstraint]) -> Result<Int, Error> {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            return .failure(Error.typeIsNotMapped)
        }
        let table = anyTable as! Table<T>
        var sql = "SELECT COUNT(*) FROM \(table.name)"
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
                        return .failure(Error.sqliteError(code: resultCode, text: errorString))
                    }
                } while resultCode != self.apiProvider.SQLITE_DONE
                return .success(res)
            case .failure(let error):
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func avg<T, F>(_ columnKeyPath: KeyPath<T, F>, _ constraints: [SelectConstraint]) -> Result<Double?, Error> {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            return .failure(Error.typeIsNotMapped)
        }
        let table = anyTable as! Table<T>
        guard let column = table.columns.first(where: { $0.keyPath == columnKeyPath }) else {
            return .failure(Error.columnNotFound)
        }
        var sql = "SELECT AVG(\"\(column.name)\") FROM \(table.name)"
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
                        return .failure(Error.sqliteError(code: resultCode, text: errorString))
                    }
                }while resultCode != self.apiProvider.SQLITE_DONE
                return .success(res)
            case .failure(let error):
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
}
