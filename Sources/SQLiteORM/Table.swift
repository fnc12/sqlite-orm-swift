import Foundation

public class Table<T>: AnyTable {

    override var type: Any.Type {
        return T.self
    }

    func bindNonPrimaryKey(columnBinder: ColumnBinder, object: T, apiProvider: SQLiteApiProvider) throws -> Int32 {
        var resultCode = Int32(0)
        var columnIndex = 0
        for anyColumn in self.columns {
            if !anyColumn.isPrimaryKey {
                let binder = BinderImpl(columnIndex: columnIndex + 1, columnBinder: columnBinder)
                resultCode = try anyColumn.bind(binder: binder, object: object)
                columnIndex += 1
                if apiProvider.SQLITE_OK != resultCode {
                    break
                }
            }
        }
        return resultCode
    }

    func bind(columnBinder: ColumnBinder, object: T, apiProvider: SQLiteApiProvider) throws -> Int32 {
        var resultCode = Int32(0)
        for (columnIndex, anyColumn) in self.columns.enumerated() {
            let binder = BinderImpl(columnIndex: columnIndex + 1, columnBinder: columnBinder)
            resultCode = try anyColumn.bind(binder: binder, object: object)
            if apiProvider.SQLITE_OK != resultCode {
                break
            }
        }
        return resultCode
    }
}
