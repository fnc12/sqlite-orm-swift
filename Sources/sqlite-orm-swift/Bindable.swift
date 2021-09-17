import Foundation

public protocol Bindable: Any {
    func bind(to statement: Binder, index: Int) -> Int32
}

extension Int: Bindable {
    public func bind(to statement: Binder, index: Int) -> Int32 {
        return statement.bindInt(value: self, index: index)
    }
}

extension Double: Bindable {
    public func bind(to statement: Binder, index: Int) -> Int32 {
        return statement.bindDouble(value: self, index: index)
    }
}

extension String: Bindable {
    public func bind(to statement: Binder, index: Int) -> Int32 {
        return statement.bindText(value: self, index: index)
    }
}

extension Optional: Bindable where Wrapped: Bindable {
    public func bind(to statement: Binder, index: Int) -> Int32 {
        switch self {
        case .none:
            return statement.bindNull(index: index)
        case .some(let value):
            return value.bind(to: statement, index: index)
        }
    }
}
