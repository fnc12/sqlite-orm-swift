import Foundation

public struct PseudoContainer<T: Initializable> {
    let connectionRef: ConnectionRef
    let statement: Statement & ColumnBinder
    let table: Table<T>
    let apiProvider: SQLiteApiProvider
}

public struct PseudoContainerIterator<T: Initializable> {
    let pseudoContainer: PseudoContainer<T>
}

extension PseudoContainerIterator: IteratorProtocol {
    public typealias Element = Result<T, Error>

    public func next() -> Element? {
        let resultCode = self.pseudoContainer.statement.step()
        switch resultCode {
        case self.pseudoContainer.apiProvider.SQLITE_ROW:
            var object = T()
            for (columnIndex, anyColumn) in self.pseudoContainer.table.columns.enumerated() {
                let columnValuePointer = self.pseudoContainer.statement.columnValuePointer(with: columnIndex)
                do {
                    try anyColumn.assign(object: &object, sqliteValue: columnValuePointer)
                } catch let error as Error {
                    return .failure(error)
                } catch {
                    return .failure(Error.unknownError)
                }
            }
            return .success(object)
        case self.pseudoContainer.apiProvider.SQLITE_DONE:
            return nil
        default:
            let errorString = self.pseudoContainer.connectionRef.errorMessage
            return .failure(Error.sqliteError(code: resultCode, text: errorString))
        }
    }
}

extension PseudoContainer: Sequence {

    public func makeIterator() -> PseudoContainerIterator<T> {
        return .init(pseudoContainer: self)
    }
}
