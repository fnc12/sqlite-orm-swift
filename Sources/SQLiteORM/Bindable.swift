import Foundation

public protocol Bindable: Any {
    func bind(to binder: Binder) -> Int32

    static func sqliteTypeName() -> String
}

extension Int: Bindable {
    public func bind(to binder: Binder) -> Int32 {
        return binder.bindInt(value: self)
    }

    public static func sqliteTypeName() -> String {
        return "INTEGER"
    }
}

extension UInt: Bindable {
    public func bind(to binder: Binder) -> Int32 {
        return binder.bindInt(value: Int(self))
    }

    public static func sqliteTypeName() -> String {
        return "INTEGER"
    }
}

extension Bool: Bindable {
    public func bind(to binder: Binder) -> Int32 {
        return binder.bindInt(value: self ? 1 : 0)
    }

    public static func sqliteTypeName() -> String {
        return "INTEGER"
    }
}

extension Double: Bindable {
    public func bind(to binder: Binder) -> Int32 {
        return binder.bindDouble(value: self)
    }

    public static func sqliteTypeName() -> String {
        return "REAL"
    }
}

extension Float: Bindable {
    public func bind(to binder: Binder) -> Int32 {
        return binder.bindDouble(value: Double(self))
    }

    public static func sqliteTypeName() -> String {
        return "REAL"
    }
}

extension String: Bindable {
    public func bind(to binder: Binder) -> Int32 {
        return binder.bindText(value: self)
    }

    public static func sqliteTypeName() -> String {
        return "TEXT"
    }
}

extension Optional: Bindable where Wrapped: Bindable {
    public func bind(to binder: Binder) -> Int32 {
        switch self {
        case .none:
            return binder.bindNull()
        case .some(let value):
            return value.bind(to: binder)
        }
    }

    public static func sqliteTypeName() -> String {
        return Wrapped.sqliteTypeName()
    }
}
