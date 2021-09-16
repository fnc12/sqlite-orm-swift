import Foundation

public class Column<T, V>: AnyColumn {
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
    
    override func assign<O>(object: inout O, statement: Statement, columnIndex: Int) throws {
        guard O.self == T.self else {
            throw Error.unknownType
        }
        var tObject = object as! T
        switch V.self {
        case is Int.Type:
            let intValue = statement.columnInt(index: columnIndex)
            let vValue = intValue as! V
            tObject[keyPath: self.keyPath] = vValue
        case is String.Type:
            let stringValue = statement.columnText(index: columnIndex)
            tObject[keyPath: self.keyPath] = stringValue as! V
        default:
            throw Error.unknownType
        }
        object = tObject as! O
    }
    
    override func assign<O>(object: inout O, sqliteValue: SQLiteValue) throws {
        if O.self == T.self {
            var tObject = object as! T
            switch V.self {
            case is Int.Type:
                let intValue = sqliteValue.integer
                let vValue = intValue as! V
                tObject[keyPath: self.keyPath] = vValue
            case is String.Type:
                let stringValue = sqliteValue.text
                tObject[keyPath: self.keyPath] = stringValue as! V
            default:
                throw Error.unknownType
            }
            object = tObject as! O
        }else{
            throw Error.unknownType
        }
    }
    
    override func bind<O>(statement: Statement, object: O, index: Int) throws -> Int32 {
        var resultCode = Int32(0)
        guard O.self == T.self else {
            throw Error.typeMismatch
        }
        let tObject = object as! T
        switch V.self {
        case is Int.Type:
            let intValue = tObject[keyPath: self.keyPath] as! Int
            resultCode = statement.bindInt(value: intValue, index: index)
        case is Int?.Type:
            if let intValue = tObject[keyPath: self.keyPath] as! Int? {
                resultCode = statement.bindInt(value: intValue, index: index)
            }else{
                resultCode = statement.bindNull(index: index)
            }
        case is String.Type:
            let stringValue = tObject[keyPath: self.keyPath] as! String
            resultCode = statement.bindText(value: stringValue, index: index)
        case is String?.Type:
            if let stringValue = tObject[keyPath: self.keyPath] as! String? {
                resultCode = statement.bindText(value: stringValue, index: index)
            }else{
                resultCode = statement.bindNull(index: index)
            }
        default:
            throw Error.unknownType
        }
        return resultCode
    }
    
    override var fieldType: Any.Type {
        return V.self
    }
}
