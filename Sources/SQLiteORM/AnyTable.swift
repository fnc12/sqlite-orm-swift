import Foundation

public class AnyTable: NSObject {
    let name: String
    let columns: [AnyColumn]
    
    public init(name: String, columns: AnyColumn...) {
        self.name = name
        self.columns = columns
        super.init()
    }
    
    var type: Any.Type {
        return Void.self
    }
    
    func forEachNonPrimaryKeyColumn(closure: (_ column: AnyColumn, _ index: Int) -> ()) {
        var index = 0
        for column in self.columns {
            if !column.isPrimaryKey {
                closure(column, index)
                index += 1
            }
        }
    }
    
    var nonPrimaryKeyColumnNamesCount: Int {
        var res = 0
        for column in self.columns {
            if !column.isPrimaryKey {
                res += 1
            }
        }
        return res
    }
    
    var primaryKeyColumnNames: [String] {
        var res = [String]()
        for column in self.columns {
            if column.isPrimaryKey {
                res.append(column.name)
            }
        }
        return res
    }
    
    var tableInfo: [TableInfo] {
        var res = [TableInfo]()
        res.reserveCapacity(self.columns.count)
        for column in self.columns {
            let typeName = column.sqliteTypeName
            let isPrimaryKey = column.isPrimaryKey ? 1 : 0
            let isNotNull = column.isNotNull
            res.append(TableInfo(cid: -1, name: column.name, type: typeName, notNull: isNotNull, dfltValue: "", pk: isPrimaryKey))
        }
        return res
    }
}
