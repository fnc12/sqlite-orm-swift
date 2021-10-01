import Foundation

public enum Error: Swift.Error {
    case typeIsNotMapped
    case columnNotFound
    case sqliteError(code: Int32, text: String)
    case databaseIsNull
    case statementIsNull
    case valueIsNull
    case unknownType
    case columnsCountMismatch(statementColumnsCount: Int, storageColumnsCount: Int)
    case failedCastingSwiftStringToCString
    case invalidBuilder
    case unableToGetObjectWithoutPrimaryKeys
    case unableToDeleteObjectWithoutPrimaryKeys
}
