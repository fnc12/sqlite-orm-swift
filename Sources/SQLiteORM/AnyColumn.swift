import Foundation

/// This is a base class for all columns. It stores type independent information: name and
/// constraints.
public class AnyColumn: NSObject {
    let name: String
    let constraints: [ColumnConstraint]
    private let _keyPath: AnyKeyPath

    init(name: String, constraints: [ColumnConstraint], keyPath: AnyKeyPath) {
        self.name = name
        self.constraints = constraints
        self._keyPath = keyPath
        super.init()
    }

    /// Returns `true` if this column has `PRIMARY KEY` constraint and `false` otherwise.
    ///
    /// - complexity *O(n)* where *n* is amount of constraints stored inside this column.
    var isPrimaryKey: Bool {
        return self.constraints.contains(where: {
            switch $0 {
            case .primaryKey:
                return true
            default:
                return false
            }
        })
    }

    ///  Returns key path stored within this column.
    ///  Must be overridden in subclass.
    var keyPath: AnyKeyPath {
        return self._keyPath
    }

    /// Returns `true` if this column has `NOT NULL` constraint and `false` otherwise.
    ///
    /// - complexity *O(n)* where *n* is amount of constraints stored inside this column.
    var isNotNull: Bool {
        return self.constraints.contains(where: {
            switch $0 {
            case .notNull:
                return true
            default:
                return false
            }
        })
    }

    /// This is a base property that must be overridden by subclasses.
    /// This text is used when `Storage.syncSchema` call creates a table.
    /// Returns SQLite type representation of field type of this column. E.g. `TEXT` for
    /// `String`, `INTEGER` for `Int`, `REAL` for `Double` etc.
    var sqliteTypeName: String {
        return ""
    }

    /// Used to bind a value stored inside a field from `object`.
    /// This function must be overridden by subclasses.
    ///
    /// - Parameter binder: binder object used to bind values.
    /// - Parameter object: object of type mapped to this column.
    /// - Returns: SQLite code returned by `sqlite3_bind_*` routine called within this function.
    func bind<O>(binder: Binder, object: O) throws -> Int32 {
        return 0
    }

    /// Use this function to obtain value from SQLite value and assign it to a field mapped
    /// with this column.
    ///
    /// - Parameter object: object passed by reference which will be modified after this call.
    /// - Parameter sqliteValue: object used to obtain typed data dependent of field type if this column.
    func assign<O>(object: inout O, sqliteValue: SQLiteValue) throws {
        // ..
    }
}

extension AnyColumn: Serializable {
    public func serialize(with serializationContext: SerializationContext) -> String {
        let typeString = self.sqliteTypeName
        var res = "\(self.name) \(typeString)"
        for constraint in self.constraints {
            let constraintString = constraint.serialize(with: serializationContext)
            res += " "
            res += constraintString
        }
        return res
    }
}
