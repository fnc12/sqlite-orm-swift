import Foundation

public protocol ColumnBinder: AnyObject {
    func bindInt(value: Int) -> Int32
    func bindDouble(value: Double) -> Int32
    func bindText(value: String) -> Int32
    func bindNull() -> Int32
}

class ColumnBinderImpl: NSObject {
    let columnIndex: Int
    let binder: Binder
    
    init(columnIndex: Int, binder: Binder) {
        self.columnIndex = columnIndex
        self.binder = binder
        super.init()
    }
}

extension ColumnBinderImpl: ColumnBinder {
    
    func bindInt(value: Int) -> Int32 {
        return self.binder.bindInt(value: value, index: self.columnIndex)
    }
    
    func bindDouble(value: Double) -> Int32 {
        return self.binder.bindDouble(value: value, index: self.columnIndex)
    }
    
    func bindText(value: String) -> Int32 {
        return self.binder.bindText(value: value, index: self.columnIndex)
    }
    
    func bindNull() -> Int32 {
        return self.binder.bindNull(index: self.columnIndex)
    }
}
