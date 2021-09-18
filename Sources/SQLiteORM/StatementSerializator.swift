import Foundation

func serialize(order: Order) -> String {
    switch order {
    case .asc: return "ASC"
    case .desc: return "DESC"
    }
}

func serialize(conflictClause: ConflictClause) -> String {
    var res = "ON CONFLICT "
    switch conflictClause {
    case .rollback: res += "ROLLBACK"
    case .abort: res += "ABORT"
    case .fail: res += "FAIL"
    case .ignore: res += "IGNORE"
    case .replace: res += "REPLACE"
    }
    return res
}

func serialize(columnConstraint: ColumnConstraint) -> String {
    switch columnConstraint {
    case .primaryKey(let orderMaybe, let conflictClauseMaybe, let autoincrement):
        var res = "PRIMARY KEY"
        if let order = orderMaybe {
            let orderString = serialize(order: order)
            res += " "
            res += orderString
        }
        if let conflictClause = conflictClauseMaybe {
            let conflictClauseString = serialize(conflictClause: conflictClause)
            res += " "
            res += conflictClauseString
        }
        if autoincrement {
            res += " AUTOINCREMENT"
        }
        return res
    case .notNull(let conflictClauseMaybe):
        var res = "NOT NULL"
        if let conflictClause = conflictClauseMaybe {
            let conflictClauseString = serialize(conflictClause: conflictClause)
            res += " "
            res += conflictClauseString
        }
        return res
    case .unique(let conflictClauseMaybe):
        var res = "UNIQUE"
        if let conflictClause = conflictClauseMaybe {
            let conflictClauseString = serialize(conflictClause: conflictClause)
            res += " "
            res += conflictClauseString
        }
        return res
    }
}

func serialize(column: AnyColumn) -> String {
    let typeString = column.sqliteTypeName
    var res = "\(column.name) \(typeString)"
    for constraint in column.constraints {
        let constraintString = serialize(columnConstraint: constraint)
        res += " "
        res += constraintString
    }
    return res
}
