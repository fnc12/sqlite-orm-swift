import Foundation

final class ColumnValuePointer: NSObject {
    let columnIndex: Int
    let stmt: OpaquePointer!
    let apiProvider: SQLiteApiProvider
    
    init(columnIndex: Int, stmt: OpaquePointer!, apiProvider: SQLiteApiProvider) {
        self.columnIndex = columnIndex
        self.stmt = stmt
        self.apiProvider = apiProvider
        super.init()
    }
}

extension ColumnValuePointer: SQLiteValue {
    
    var isValid: Bool {
        return self.stmt != nil
    }
    
    var integer: Int {
        return Int(self.apiProvider.sqlite3ColumnInt(self.stmt, Int32(self.columnIndex)))
    }
    
    var double: Double {
        return self.apiProvider.sqlite3ColumnDouble(self.stmt, Int32(self.columnIndex))
    }
    
    var text: String {
        guard let cString = self.apiProvider.sqlite3ColumnText(self.stmt, Int32(self.columnIndex)) else {
            return ""
        }
        return String(cString: cString)
    }
    
    var isNull: Bool {
        return self.apiProvider.sqlite3ColumnType(self.stmt, Int32(self.columnIndex)) == self.apiProvider.SQLITE_NULL
    }
}
