import Foundation

/// Class used to make columns which contains configuration of mapping. One `Column` instance
/// contains a pair of name of column and of `KeyPath` to a field with optional column constrains array.
///
/// # Generic parameters:
///     - T: object type. Can be `class` or `struct`.
///     - V: field type. Must inherit from `Bindable` and `ConstructableFromSQLiteValue` protocols
///
/// # Examples:
///     Column(name: "identifier", keyPath: \User.id)
///     Column(name: "first_name", keyPath: \User.firstName, constraints: primaryKey(), notNull())
///
public class Column<T, V>: AnyColumn where V: Bindable & ConstructableFromSQLiteValue {
    
    /// The simplest constructor used to create a column without column constraints.
    ///
    /// # Examples:
    ///     Column(name: "identifier", keyPath: \User.id)
    ///     Column(name: "country_name", keyPath: \User.countryName)
    public init(name: String, keyPath: WritableKeyPath<T, V>) {
        super.init(name: name, constraints: [], keyPath: keyPath)
    }
    
    /// Constructor used to create a column with column constraints.
    ///
    /// # Examples:
    ///     Column(name: "id", keyPath: \User.id, constraints: primaryKey(), notNull())
    ///     Column(name: "first_name", keyPath: \User.firstName, constraints: notNull())
    public init(name: String, keyPath: WritableKeyPath<T, V>, constraints: ConstraintBuilder...) {
        let constraintsArray = constraints.map{ $0.constraint }
        super.init(name: name, constraints: constraintsArray, keyPath: keyPath)
    }
    
    /// Returns `WritableKeyPath` stored in this column. This is a computed property
    /// cause keyPath is actually stored inside base class
    override var keyPath: WritableKeyPath<T, V> {
        return super.keyPath as! WritableKeyPath<T, V>
    }
    
    /// This is overridden function of superclass. Created for internal usage only.
    ///
    /// - Parameter object: object passed by reference which will be modified after this call.
    /// - Parameter sqliteValue: object used to obtain typed data dependent of field type if this column.
    ///
    /// - Throws:
    ///     `Error.unknownType` if `O` is not equal to `Self.T`
    override func assign<O>(object: inout O, sqliteValue: SQLiteValue) throws {
        guard O.self == T.self else {
            throw Error.unknownType
        }
        var tObject = object as! T
        tObject[keyPath: self.keyPath] = .init(sqliteValue: sqliteValue)
        object = tObject as! O
    }
    
    /// This is overridden function of superclass. Created for internal usage only.
    ///
    /// - Parameter binder: binder object used to bind values.
    /// - Parameter object: object of type mapped to this column.
    /// - Returns: SQLite code returned by `sqlite3_bind_*` routine called within this function.
    ///
    /// - Throws:
    ///     `Error.unknownType` if `O` is not equal to `Self.T`
    override func bind<O>(binder: Binder, object: O) throws -> Int32 {
        guard O.self == T.self else {
            throw Error.unknownType
        }
        let tObject = object as! T
        return tObject[keyPath: self.keyPath].bind(to: binder)
    }
    
    /// This is overridden property of superclass. Created for internal usage only.
    /// This text is used when `Storage.syncSchema` call creates a table.
    /// Returns SQLite type representation of field type of this column. E.g. `TEXT` for
    /// `String`, `INTEGER` for `Int`, `REAL` for `Double` etc.
    override var sqliteTypeName: String {
        return V.sqliteTypeName()
    }
}
