import Foundation

public protocol Bindable: Any {
    func bind(to binder: Binder, index: Int) -> Int32
}

extension Int: Bindable {
    public func bind(to binder: Binder, index: Int) -> Int32 {
        return binder.bindInt(value: self, index: index)
    }
}

extension Double: Bindable {
    public func bind(to binder: Binder, index: Int) -> Int32 {
        return binder.bindDouble(value: self, index: index)
    }
}

extension String: Bindable {
    public func bind(to binder: Binder, index: Int) -> Int32 {
        return binder.bindText(value: self, index: index)
    }
}

extension Optional: Bindable where Wrapped: Bindable {
    public func bind(to binder: Binder, index: Int) -> Int32 {
        switch self {
        case .none:
            return binder.bindNull(index: index)
        case .some(let value):
            return value.bind(to: binder, index: index)
        }
    }
}
