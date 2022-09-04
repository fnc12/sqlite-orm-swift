import Foundation

extension StorageCoreImpl: SchemaProvider {

    public func columnName<T, F>(keyPath: KeyPath<T, F>) -> Result<String, Error> {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            return .failure(Error.typeIsNotMapped)
        }
        guard let column = anyTable.columns.first(where: { $0.keyPath == keyPath }) else {
            return .failure(Error.columnNotFound)
        }
        return .success(column.name)
    }

    public func columnNameWithTable<T, F>(keyPath: KeyPath<T, F>) -> Result<String, Error> {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            return .failure(Error.typeIsNotMapped)
        }
        guard let column = anyTable.columns.first(where: { $0.keyPath == keyPath }) else {
            return .failure(Error.columnNotFound)
        }
        return .success("\(anyTable.name).\"\(column.name)\"")    //  TODO: move double quotes to 'serialize' function
    }

    public func tableName<T>(type: T.Type) -> Result<String, Error> {
        guard let anyTable = self.tables.first(where: { $0.type == T.self }) else {
            return .failure(Error.typeIsNotMapped)
        }
        return .success(anyTable.name)
    }
}
