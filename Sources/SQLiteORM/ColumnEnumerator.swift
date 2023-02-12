import Foundation

class ColumnEnumerator {
    let table: AnyTable
    
    init(table: AnyTable) {
        self.table = table
    }
    
    var count: Int {
        var result = 0
        for element in self.table.elements {
            switch element {
            case .column:
                result += 1
            }
        }
        return result
    }
}

struct ColumnIterator {
    let columnEnumerator: ColumnEnumerator
    var columnIndex = -1
    var elementIndex = -1
}

extension ColumnIterator: IteratorProtocol {
    typealias Element = (Int, AnyColumn)
    
    mutating func next() -> Element? {
        self.elementIndex += 1
        guard self.elementIndex < self.columnEnumerator.table.elements.count else { return nil }
        switch self.columnEnumerator.table.elements[self.elementIndex] {
        case .column(let column):
            self.columnIndex += 1
            return (self.columnIndex, column)
        }
    }
}

extension ColumnEnumerator: Sequence {
    func makeIterator() -> ColumnIterator {
        .init(columnEnumerator: self)
    }
}
