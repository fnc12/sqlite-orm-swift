import Foundation

public class AnyColumn: NSObject {
    let name: String
    let constraints: [ColumnConstraint]
    
    init(name: String, constraints: [ColumnConstraint]) {
        self.name = name
        self.constraints = constraints
        super.init()
    }
    
    var isPrimaryKey: Bool {
        return self.constraints.contains(where: {
            switch $0 {
            case .primaryKey(_, _, _):
                return true
            default:
                return false
            }
        })
    }
    
    var isNotNull: Bool {
        return self.constraints.contains(where: {
            switch $0 {
            case .notNull(_):
                return true
            default:
                return false
            }
        })
    }
    
    var sqliteTypeName: String {
        return ""
    }
    
    func bind<O>(binder: Binder, object: O) throws -> Int32 {
        return 0
    }
    
    func assign<O>(object: inout O, sqliteValue: SQLiteValue) throws {
        //..
    }
    
    var fieldType: Any.Type {
        return Void.self
    }
}
