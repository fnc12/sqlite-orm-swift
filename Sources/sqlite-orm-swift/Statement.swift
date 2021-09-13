import Foundation

internal class Statement: NSObject {
    private let stmt: OpaquePointer
    private let apiProvider: SQLiteApiProvider
    
    init(stmt: OpaquePointer, apiProvider: SQLiteApiProvider) {
        self.stmt = stmt
        self.apiProvider = apiProvider
        super.init()
    }
    
    deinit {
        self.apiProvider.sqlite3Finalize(self.stmt)
    }
    
    func step() -> Int32 {
        return self.apiProvider.sqlite3Step(self.stmt)
    }
    
    func columnCount() -> Int32 {
        return self.apiProvider.sqlite3ColumnCount(self.stmt)
    }
    
    func columnValue(columnIndex: Int) -> SQLiteValue {
        let handle = self.apiProvider.sqlite3ColumnValue(self.stmt, Int32(columnIndex))
        return SQLiteValue(handle: handle, apiProvider: self.apiProvider)
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
    
    func bind(value: Any, index: Int) throws -> Int32 {
        switch type(of: value) {
        case is Int.Type:
            return self.bindInt(value: value as! Int, index: index)
        case is String.Type:
            return self.bindText(value: value as! String, index: index)
        default:
            throw Error.unknownType
        }
    }
    
    func bindText(value: String, index: Int) -> Int32 {
        let nsString = value as NSString
        return self.apiProvider.sqlite3BindText(self.stmt, Int32(index), nsString.utf8String, -1, self.apiProvider.SQLITE_TRANSIENT)
    }
    
    func bindInt(value: Int, index: Int) -> Int32 {
        return self.apiProvider.sqlite3BindInt(self.stmt, Int32(index), Int32(value))
    }
}