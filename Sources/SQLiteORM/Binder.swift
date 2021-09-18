import Foundation

public protocol Binder: AnyObject {
    func bindInt(value: Int) -> Int32
    func bindDouble(value: Double) -> Int32
    func bindText(value: String) -> Int32
    func bindNull() -> Int32
}

class BinderImpl: NSObject {
    let columnIndex: Int
    let columnBinder: ColumnBinder
    
    init(columnIndex: Int, columnBinder: ColumnBinder) {
        self.columnIndex = columnIndex
        self.columnBinder = columnBinder
        super.init()
    }
}

extension BinderImpl: Binder {
    
    func bindInt(value: Int) -> Int32 {
        return self.columnBinder.bindInt(value: value, index: self.columnIndex)
    }
    
    func bindDouble(value: Double) -> Int32 {
        return self.columnBinder.bindDouble(value: value, index: self.columnIndex)
    }
    
    func bindText(value: String) -> Int32 {
        return self.columnBinder.bindText(value: value, index: self.columnIndex)
    }
    
    func bindNull() -> Int32 {
        return self.columnBinder.bindNull(index: self.columnIndex)
    }
}
