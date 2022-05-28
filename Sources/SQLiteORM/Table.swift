import Foundation

public class Table<T>: AnyTable {

    override var type: Any.Type {
        return T.self
    }

    func bindNonPrimaryKey(columnBinder: ColumnBinder, object: T, apiProvider: SQLiteApiProvider) throws -> Int32 {
        var result = Int32(0)
        var columnIndex = 0
        for anyColumn in self.columns {
            if !anyColumn.isPrimaryKey {
                let binder = BinderImpl(columnIndex: columnIndex + 1, columnBinder: columnBinder)
                let bindResult = anyColumn.bind(binder: binder, object: object)
                switch bindResult {
                case .success(let resultCode):
                    result = resultCode
                    columnIndex += 1
                    if apiProvider.SQLITE_OK != result {
                        break
                    }
                case .failure(let error):
                    throw error
                }
            }
        }
        return result
    }

    func bind(columnBinder: ColumnBinder, object: T, apiProvider: SQLiteApiProvider) throws -> Int32 {
        var result = Int32(0)
        for (columnIndex, anyColumn) in self.columns.enumerated() {
            let binder = BinderImpl(columnIndex: columnIndex + 1, columnBinder: columnBinder)
            let bindResult = anyColumn.bind(binder: binder, object: object)
            switch bindResult {
            case .success(let resultCode):
                result = resultCode
                if apiProvider.SQLITE_OK != result {
                    break
                }
            case .failure(let error):
                throw error
            }
        }
        return result
    }
}
