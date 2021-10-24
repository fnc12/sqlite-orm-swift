import Foundation

public protocol SchemaProvider {
    func columnNameWithTable<T, F>(keyPath: KeyPath<T, F>) throws -> String
    func columnName<T, F>(keyPath: KeyPath<T, F>) throws -> String
}
