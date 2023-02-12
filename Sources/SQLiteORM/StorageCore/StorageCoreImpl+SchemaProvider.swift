import Foundation

extension StorageCoreImpl: SchemaProvider {

    public func columnName<T, F>(keyPath: KeyPath<T, F>) -> Result<String, Error> {
        switch self.findColumn(keyPath: keyPath) {
        case .success(let (_, column)):
            return .success(column.name)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    private func findColumn<T, F>(keyPath: KeyPath<T, F>) -> Result<(AnyTable, AnyColumn), Error> {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            return .failure(Error.typeIsNotMapped)
        }
        let column = { () -> AnyColumn? in
            for element in anyTable.elements {
                switch element {
                case .column(let column):
                    if column.keyPath == keyPath {
                        return column
                    }
                }
            }
            return nil
        }()
        guard let column else {
            return .failure(Error.columnNotFound)
        }
        return .success((anyTable, column))
    }

    public func columnNameWithTable<T, F>(keyPath: KeyPath<T, F>) -> Result<String, Error> {
        switch self.findColumn(keyPath: keyPath) {
        case .success(let (table, column)):
            return .success("\(table.name).\"\(column.name)\"")    //  TODO: move double quotes to 'serialize' function
        case .failure(let error):
            return .failure(error)
        }
    }

    public func tableName<T>(type: T.Type) -> Result<String, Error> {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            return .failure(Error.typeIsNotMapped)
        }
        return .success(anyTable.name)
    }
}
