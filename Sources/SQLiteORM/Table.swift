import Foundation

public class Table<T>: AnyTable {

    override var type: Any.Type {
        return T.self
    }

    func bindNonPrimaryKey(columnBinder: ColumnBinder, object: T, apiProvider: SQLiteApiProvider) -> Result<Int32, Error> {
        var result = Int32(0)
        var columnIndex = 0
        for element in self.elements {
            switch element {
            case .column(let anyColumn):
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
                        return .failure(error)
                    }
                }
            }
        }
        return .success(result)
    }

    func bind(columnBinder: ColumnBinder, object: T, apiProvider: SQLiteApiProvider) -> Result<Int32, Error> {
        var result = Int32(0)
        var columnIndex = 0
        for element in self.elements {
            switch element {
            case .column(let anyColumn):
                let binder = BinderImpl(columnIndex: columnIndex + 1, columnBinder: columnBinder)
                let bindResult = anyColumn.bind(binder: binder, object: object)
                switch bindResult {
                case .success(let resultCode):
                    result = resultCode
                    if apiProvider.SQLITE_OK != result {
                        break
                    }
                case .failure(let error):
                    return .failure(error)
                }
                columnIndex += 1
            }
        }
        return .success(result)
    }
}
