import Foundation

public protocol Binder: AnyObject {
    func bindInt(value: Int) -> Int32
    func bindDouble(value: Double) -> Int32
    func bindText(value: String) -> Int32
    func bindNull() -> Int32
}

class ColumnBinderImpl: NSObject {
    let columnIndex: Int
    let futureColumnBinder: FutureColumnBinder
    
    init(columnIndex: Int, futureColumnBinder: FutureColumnBinder) {
        self.columnIndex = columnIndex
        self.futureColumnBinder = futureColumnBinder
        super.init()
    }
}

extension ColumnBinderImpl: Binder {
    
    func bindInt(value: Int) -> Int32 {
        return self.futureColumnBinder.bindInt(value: value, index: self.columnIndex)
    }
    
    func bindDouble(value: Double) -> Int32 {
        return self.futureColumnBinder.bindDouble(value: value, index: self.columnIndex)
    }
    
    func bindText(value: String) -> Int32 {
        return self.futureColumnBinder.bindText(value: value, index: self.columnIndex)
    }
    
    func bindNull() -> Int32 {
        return self.futureColumnBinder.bindNull(index: self.columnIndex)
    }
}
