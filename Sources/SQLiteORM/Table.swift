import Foundation

public class Table<T>: AnyTable {
    
    override var type: Any.Type {
        return T.self
    }
    
    func bindNonPrimaryKey(statement: Binder, object: T, apiProvider: SQLiteApiProvider) throws -> Int32 {
        var resultCode = Int32(0)
        var columnIndex = 0
        for anyColumn in self.columns {
            if !anyColumn.isPrimaryKey {
                resultCode = try anyColumn.bind(binder: statement, object: object, index: columnIndex + 1)
                columnIndex += 1
                if apiProvider.SQLITE_OK != resultCode {
                    break
                }
            }
        }
        return resultCode
    }
    
    func bind(statement: Binder, object: T, apiProvider: SQLiteApiProvider) throws -> Int32 {
        var resultCode = Int32(0)
        for (columnIndex, anyColumn) in self.columns.enumerated() {
            resultCode = try anyColumn.bind(binder: statement, object: object, index: columnIndex + 1)
            if apiProvider.SQLITE_OK != resultCode {
                break
            }
        }
        return resultCode
    }
}
