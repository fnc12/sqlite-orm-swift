import Foundation

public protocol Bindable: Any {
    func bind(to columnBinder: ColumnBinder) -> Int32
    
    static func sqliteTypeName() -> String
}

extension Int: Bindable {
    public func bind(to columnBinder: ColumnBinder) -> Int32 {
        return columnBinder.bindInt(value: self)
    }
    
    public static func sqliteTypeName() -> String {
        return "INTEGER"
    }
}

extension UInt: Bindable {
    public func bind(to columnBinder: ColumnBinder) -> Int32 {
        return columnBinder.bindInt(value: Int(self))
    }
    
    public static func sqliteTypeName() -> String {
        return "INTEGER"
    }
}

extension Bool: Bindable {
    public func bind(to columnBinder: ColumnBinder) -> Int32 {
        return columnBinder.bindInt(value: self ? 1 : 0)
    }
    
    public static func sqliteTypeName() -> String {
        return "INTEGER"
    }
}

extension Double: Bindable {
    public func bind(to columnBinder: ColumnBinder) -> Int32 {
        return columnBinder.bindDouble(value: self)
    }
    
    public static func sqliteTypeName() -> String {
        return "REAL"
    }
}

extension Float: Bindable {
    public func bind(to columnBinder: ColumnBinder) -> Int32 {
        return columnBinder.bindDouble(value: Double(self))
    }
    
    public static func sqliteTypeName() -> String {
        return "REAL"
    }
}

extension String: Bindable {
    public func bind(to columnBinder: ColumnBinder) -> Int32 {
        return columnBinder.bindText(value: self)
    }
    
    public static func sqliteTypeName() -> String {
        return "TEXT"
    }
}

extension Optional: Bindable where Wrapped: Bindable {
    public func bind(to columnBinder: ColumnBinder) -> Int32 {
        switch self {
        case .none:
            return columnBinder.bindNull()
        case .some(let value):
            return value.bind(to: columnBinder)
        }
    }
    
    public static func sqliteTypeName() -> String {
        return Wrapped.sqliteTypeName()
    }
}
