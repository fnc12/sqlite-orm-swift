import Foundation

extension Storage: SchemaProvider {

    public func columnName<T, F>(keyPath: KeyPath<T, F>) throws -> String {
        guard let anyTable = self.storageCore.tables.first(where: { $0.type == T.self }) else {
            throw Error.typeIsNotMapped
        }
        guard let column = anyTable.columns.first(where: { $0.keyPath == keyPath }) else {
            throw Error.columnNotFound
        }
        return column.name
    }

    public func columnNameWithTable<T, F>(keyPath: KeyPath<T, F>) throws -> String {
        guard let anyTable = self.storageCore.tables.first(where: { $0.type == T.self }) else {
            throw Error.typeIsNotMapped
        }
        guard let column = anyTable.columns.first(where: { $0.keyPath == keyPath }) else {
            throw Error.columnNotFound
        }
        return "\(anyTable.name).\"\(column.name)\""    //  TODO: move double quotes to 'serialize' function
    }

    public func tableName<T>(type: T.Type) throws -> String {
        guard let anyTable = self.storageCore.tables.first(where: { $0.type == T.self }) else {
            throw Error.typeIsNotMapped
        }
        return anyTable.name
    }
}
