import Foundation

/// This is a base class for table. Tables are created using subclass instances.
/// This class stores table name and columns information.
public class AnyTable: NSObject {
    let name: String
    let elements: [TableElement]

    /// Constructor that must be called from subclass constructor.
    public init(name: String, elements: [TableElementProtocol]) {
        self.name = name
        self.elements = elements.map{ $0.tableElement }
        super.init()
    }

    /// Getter for type mapped to this table. Got to be overridden inside subclass
    var type: Any.Type {
        return Void.self
    }
    
    func enumeratedColumns() -> ColumnEnumerator {
        .init(table: self)
    }
    
    func columnBy(keyPath: AnyKeyPath) -> AnyColumn? {
        for element in elements {
            switch element {
            case .column(let column):
                if column.keyPath == keyPath {
                    return column
                }
            }
        }
        return nil
    }

    func forEachNonPrimaryKeyColumn(closure: (_ column: AnyColumn, _ index: Int) -> Void) {
        var index = 0
        for element in self.elements {
            switch element {
            case .column(let column):
                if !column.isPrimaryKey {
                    closure(column, index)
                    index += 1
                }
            }
        }
    }

    var nonPrimaryKeyColumnNamesCount: Int {
        var res = 0
        for element in self.elements {
            switch element {
            case .column(let column):
                if !column.isPrimaryKey {
                    res += 1
                }
            }
        }
        return res
    }

    var primaryKeyColumnNames: [String] {
        var res = [String]()
        for element in self.elements {
            switch element {
            case .column(let column):
                if column.isPrimaryKey {
                    res.append(column.name)
                }
            }
        }
        return res
    }

    var tableInfo: [TableInfo] {
        var res = [TableInfo]()
        res.reserveCapacity(self.elements.count)
        for element in self.elements {
            switch element {
            case .column(let column):
                let typeName = column.sqliteTypeName
                let isPrimaryKey = column.isPrimaryKey ? 1 : 0
                let isNotNull = column.isNotNull
                res.append(TableInfo(cid: -1, name: column.name, type: typeName, notNull: isNotNull, dfltValue: "", pk: isPrimaryKey))
            }
        }
        return res
    }
}
