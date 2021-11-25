import Foundation

public struct View<T: Initializable> {
    let connectionRef: ConnectionRef
    let statement: Statement & ColumnBinder
    let table: Table<T>
    let apiProvider: SQLiteApiProvider
}

public struct ViewIterator<T: Initializable> {
    let view: View<T>
}

extension ViewIterator: IteratorProtocol {
    public typealias Element = Result<T, Error>

    public func next() -> Element? {
        let resultCode = self.view.statement.step()
        switch resultCode {
        case self.view.apiProvider.SQLITE_ROW:
            var object = T()
            for (columnIndex, anyColumn) in self.view.table.columns.enumerated() {
                let columnValuePointer = self.view.statement.columnValuePointer(with: columnIndex)
                do {
                    try anyColumn.assign(object: &object, sqliteValue: columnValuePointer)
                } catch let error as Error {
                    return .failure(error)
                } catch {
                    return .failure(Error.unknownError)
                }
            }
            return .success(object)
        case self.view.apiProvider.SQLITE_DONE:
            return nil
        default:
            let errorString = self.view.connectionRef.errorMessage
            return .failure(Error.sqliteError(code: resultCode, text: errorString))
        }
    }
}

extension View: Sequence {

    public func makeIterator() -> ViewIterator<T> {
        return .init(view: self)
    }
}
