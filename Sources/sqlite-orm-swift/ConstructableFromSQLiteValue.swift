import Foundation

public protocol ConstructableFromSQLiteValue: Any {
    init(sqliteValue: SQLiteValue)
}

extension Int: ConstructableFromSQLiteValue {
    public init(sqliteValue: SQLiteValue) {
        self = sqliteValue.integer
    }
}

extension Double: ConstructableFromSQLiteValue {
    public init(sqliteValue: SQLiteValue) {
        self = sqliteValue.double
    }
}

extension String: ConstructableFromSQLiteValue {
    public init(sqliteValue: SQLiteValue) {
        self = sqliteValue.text
    }
}

extension Optional: ConstructableFromSQLiteValue where Wrapped: ConstructableFromSQLiteValue {
    public init(sqliteValue: SQLiteValue) {
        if sqliteValue.isNull {
            self = nil
        }else{
            self = Wrapped(sqliteValue: sqliteValue)
        }
    }
}
