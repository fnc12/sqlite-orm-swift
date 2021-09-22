import Foundation

class StatementImpl: NSObject {
    let stmt: OpaquePointer
    private let apiProvider: SQLiteApiProvider
    
    init(stmt: OpaquePointer, apiProvider: SQLiteApiProvider) {
        self.stmt = stmt
        self.apiProvider = apiProvider
        super.init()
    }
    
    deinit {
        self.apiProvider.sqlite3Finalize(self.stmt)
    }
}

extension StatementImpl: ColumnBinder {
    func bindInt(value: Int, index: Int) -> Int32 {
        return self.apiProvider.sqlite3BindInt(self.stmt, Int32(index), Int32(value))
    }
    
    func bindDouble(value: Double, index: Int) -> Int32 {
        return self.apiProvider.sqlite3BindDouble(self.stmt, Int32(index), value)
    }
    
    func bindText(value: String, index: Int) -> Int32 {
        let nsString = value as NSString
        return self.apiProvider.sqlite3BindText(self.stmt, Int32(index), nsString.utf8String, -1, self.apiProvider.SQLITE_TRANSIENT)
    }
    
    func bindNull(index: Int) -> Int32 {
        return self.apiProvider.sqlite3BindNull(self.stmt, Int32(index))
    }
}

extension StatementImpl: Statement {
    
    func columnValuePointer(with columnIndex: Int) -> SQLiteValue {
        return ColumnValuePointer(columnIndex: columnIndex, stmt: self.stmt, apiProvider: self.apiProvider)
    }
    
    func step() -> Int32 {
        return self.apiProvider.sqlite3Step(self.stmt)
    }
    
    func columnCount() -> Int32 {
        return self.apiProvider.sqlite3ColumnCount(self.stmt)
    }
    
    func columnValue(columnIndex: Int) -> SQLiteValue {
        let handle = self.apiProvider.sqlite3ColumnValue(self.stmt, Int32(columnIndex))
        return SQLiteValueImpl(handle: handle, apiProvider: self.apiProvider)
    }
    
    func columnText(index: Int) -> String {
        guard let cString = self.apiProvider.sqlite3ColumnText(self.stmt, Int32(index)) else {
            return ""
        }
        return String(cString: cString)
    }
    
    func columnInt(index: Int) -> Int {
        return Int(self.apiProvider.sqlite3ColumnInt(self.stmt, Int32(index)))
    }
    
    func columnDouble(index: Int) -> Double {
        return self.apiProvider.sqlite3ColumnDouble(self.stmt, Int32(index))
    }
}
