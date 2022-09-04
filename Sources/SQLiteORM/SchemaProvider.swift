import Foundation

public protocol SchemaProvider {
    func columnNameWithTable<T, F>(keyPath: KeyPath<T, F>) -> Result<String, Error>
    func columnName<T, F>(keyPath: KeyPath<T, F>) -> Result<String, Error>
    func tableName<T>(type: T.Type) -> Result<String, Error>
}
