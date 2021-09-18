import Foundation

public class Column<T, V>: AnyColumn where V: Bindable & ConstructableFromSQLiteValue {
    let keyPath: WritableKeyPath<T, V>
    
    public init(name: String, keyPath: WritableKeyPath<T, V>) {
        self.keyPath = keyPath
        super.init(name: name, constraints: [])
    }
    
    public init(name: String, keyPath: WritableKeyPath<T, V>, constraints: ConstraintBuilder...) {
        self.keyPath = keyPath
        let constraintsArray = constraints.map{ $0.constraint }
        super.init(name: name, constraints: constraintsArray)
    }
    
    override func assign<O>(object: inout O, sqliteValue: SQLiteValue) throws {
        guard O.self == T.self else {
            throw Error.unknownType
        }
        var tObject = object as! T
        tObject[keyPath: self.keyPath] = .init(sqliteValue: sqliteValue)
        object = tObject as! O
    }
    
    override func bind<O>(columnBinder: ColumnBinder, object: O) throws -> Int32 {
        guard O.self == T.self else {
            throw Error.unknownType
        }
        let tObject = object as! T
        return tObject[keyPath: self.keyPath].bind(to: columnBinder)
    }
    
    override var sqliteTypeName: String {
        return V.sqliteTypeName()
    }
    
    override var fieldType: Any.Type {
        return V.self
    }
}
