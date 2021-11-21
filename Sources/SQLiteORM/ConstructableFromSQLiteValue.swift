import Foundation

public protocol ConstructableFromSQLiteValue: Any {
    init(sqliteValue: SQLiteValue)
}

extension Int: ConstructableFromSQLiteValue {
    public init(sqliteValue: SQLiteValue) {
        self = sqliteValue.integer
    }
}

extension UInt: ConstructableFromSQLiteValue {
    public init(sqliteValue: SQLiteValue) {
        self = Self(sqliteValue.integer)
    }
}

extension Int64: ConstructableFromSQLiteValue {
    public init(sqliteValue: SQLiteValue) {
        self = Self(sqliteValue.integer)
    }
}

extension UInt64: ConstructableFromSQLiteValue {
    public init(sqliteValue: SQLiteValue) {
        self = Self(sqliteValue.integer)
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

extension Bool: ConstructableFromSQLiteValue {
    public init(sqliteValue: SQLiteValue) {
        self = sqliteValue.integer != 0
    }
}

extension Optional: ConstructableFromSQLiteValue where Wrapped: ConstructableFromSQLiteValue {
    public init(sqliteValue: SQLiteValue) {
        if sqliteValue.isNull {
            self = nil
        } else {
            self = Wrapped(sqliteValue: sqliteValue)
        }
    }
}
