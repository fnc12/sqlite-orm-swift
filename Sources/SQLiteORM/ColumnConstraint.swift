import Foundation

public enum ColumnConstraint {
    case primaryKey(order: Order?, conflictClause: ConflictClause?, autoincrement: Bool)
    case notNull(conflictClause: ConflictClause?)
    case unique(conflictClause: ConflictClause?)
}

extension ColumnConstraint: Serializable {
    func serialize() -> String {
        switch self {
        case .primaryKey(let orderMaybe, let conflictClauseMaybe, let autoincrement):
            var res = "PRIMARY KEY"
            if let order = orderMaybe {
                let orderString = order.serialize()
                res += " "
                res += orderString
            }
            if let conflictClause = conflictClauseMaybe {
                let conflictClauseString = conflictClause.serialize()
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
                let conflictClauseString = conflictClause.serialize()
                res += " "
                res += conflictClauseString
            }
            return res
        case .unique(let conflictClauseMaybe):
            var res = "UNIQUE"
            if let conflictClause = conflictClauseMaybe {
                let conflictClauseString = conflictClause.serialize()
                res += " "
                res += conflictClauseString
            }
            return res
        }
    }
}

extension ColumnConstraint: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case let (.primaryKey(order1, conflictClause1, autoincrement1), .primaryKey(order2, conflictClause2, autoincrement2)):
            return order1 == order2 && conflictClause1 == conflictClause2 && autoincrement1 == autoincrement2
        case let (.notNull(conflictClause1), .notNull(conflictClause2)):
            return conflictClause1 == conflictClause2
        case let (.unique(conflictClause1), .unique(conflictClause2)):
            return conflictClause1 == conflictClause2
        default:
            return false
        }
    }
}

public protocol ConstraintBuilder {
    var constraint: ColumnConstraint { get }
}

public class PrimaryKeyWithAllBuilder: ConstraintBuilder {
    let conflictClause: ConflictClause?
    let order: Order?
    let autoincrement: Bool
    
    init(conflictClause: ConflictClause?, order: Order?, autoincrement: Bool) {
        self.conflictClause = conflictClause
        self.order = order
        self.autoincrement = autoincrement
    }
    
    public var constraint: ColumnConstraint {
        return .primaryKey(order: self.order, conflictClause: self.conflictClause, autoincrement: self.autoincrement)
    }
}

public class PrimaryKeyWithConflictClauseBuilder: ConstraintBuilder {
    let conflictClause: ConflictClause
    let order: Order?
    
    init(order: Order?, conflictClause: ConflictClause) {
        self.order = order
        self.conflictClause = conflictClause
    }
    
    public var constraint: ColumnConstraint {
        return .primaryKey(order: self.order, conflictClause: self.conflictClause, autoincrement: false)
    }
    
    public func autoincrement() -> PrimaryKeyWithAllBuilder {
        return PrimaryKeyWithAllBuilder(conflictClause: self.conflictClause, order: self.order, autoincrement: true)
    }
}

public class PrimaryKeyBuilder: ConstraintBuilder {
    public var constraint: ColumnConstraint {
        return .primaryKey(order: nil, conflictClause: nil, autoincrement: false)
    }
    
    public func autoincrement() -> PrimaryKeyWithAllBuilder {
        return PrimaryKeyWithAllBuilder(conflictClause: nil, order: nil, autoincrement: true)
    }
    
    public func asc() -> PrimaryKeyBuilderWithOrder {
        return PrimaryKeyBuilderWithOrder(order: .asc)
    }
    
    public func desc() -> PrimaryKeyBuilderWithOrder {
        return PrimaryKeyBuilderWithOrder(order: .desc)
    }
    
    public class OnConflictClauseBuilder {
        let order: Order?
        
        init(order: Order?) {
            self.order = order
        }
        
        public func rollback() -> PrimaryKeyWithConflictClauseBuilder {
            return PrimaryKeyWithConflictClauseBuilder(order: self.order, conflictClause: .rollback)
        }
        
        public func abort() -> PrimaryKeyWithConflictClauseBuilder {
            return PrimaryKeyWithConflictClauseBuilder(order: self.order, conflictClause: .abort)
        }
        
        public func fail() -> PrimaryKeyWithConflictClauseBuilder {
            return PrimaryKeyWithConflictClauseBuilder(order: self.order, conflictClause: .fail)
        }
        
        public func ignore() -> PrimaryKeyWithConflictClauseBuilder {
            return PrimaryKeyWithConflictClauseBuilder(order: self.order, conflictClause: .ignore)
        }
        
        public func replace() -> PrimaryKeyWithConflictClauseBuilder {
            return PrimaryKeyWithConflictClauseBuilder(order: self.order, conflictClause: .replace)
        }
    }
    
    public func onConflict() -> OnConflictClauseBuilder {
        return OnConflictClauseBuilder(order: nil)
    }
}

public class PrimaryKeyBuilderWithOrder: ConstraintBuilder {
    let order: Order
    
    init(order: Order) {
        self.order = order
    }
    
    public var constraint: ColumnConstraint {
        return .primaryKey(order: self.order, conflictClause: nil, autoincrement: false)
    }
    
    public func onConflict() -> PrimaryKeyBuilder.OnConflictClauseBuilder {
        return PrimaryKeyBuilder.OnConflictClauseBuilder(order: self.order)
    }
    
    public func autoincrement() -> PrimaryKeyWithAllBuilder {
        return PrimaryKeyWithAllBuilder(conflictClause: nil, order: self.order, autoincrement: true)
    }
}

public class NotNullWithConflictClauseBuilder: ConstraintBuilder {
    let conflictClause: ConflictClause
    
    public var constraint: ColumnConstraint {
        return .notNull(conflictClause: self.conflictClause)
    }
    
    init(conflictClause: ConflictClause) {
        self.conflictClause = conflictClause
    }
}

public class NotNullBuilder: ConstraintBuilder {
    public class OnConflictClauseBuilder {
        
        public func rollback() -> NotNullWithConflictClauseBuilder {
            return NotNullWithConflictClauseBuilder(conflictClause: .rollback)
        }
        
        public func abort() -> NotNullWithConflictClauseBuilder {
            return NotNullWithConflictClauseBuilder(conflictClause: .abort)
        }
        
        public func fail() -> NotNullWithConflictClauseBuilder {
            return NotNullWithConflictClauseBuilder(conflictClause: .fail)
        }
        
        public func ignore() -> NotNullWithConflictClauseBuilder {
            return NotNullWithConflictClauseBuilder(conflictClause: .ignore)
        }
        
        public func replace() -> NotNullWithConflictClauseBuilder {
            return NotNullWithConflictClauseBuilder(conflictClause: .replace)
        }
    }
    
    public var constraint: ColumnConstraint {
        return .notNull(conflictClause: nil)
    }
    
    public func onConflict() -> OnConflictClauseBuilder {
        return OnConflictClauseBuilder()
    }
}

public class UniqueWithConflictClauseBuilder: ConstraintBuilder {
    let conflictClause: ConflictClause
    
    init(conflictClause: ConflictClause) {
        self.conflictClause = conflictClause
    }
    
    public var constraint: ColumnConstraint {
        return .unique(conflictClause: self.conflictClause)
    }
}

public class UniqueBuilder: ConstraintBuilder {
    public var constraint: ColumnConstraint {
        return .unique(conflictClause: nil)
    }
    
    public class OnConflictClauseBuilder {
        
        public func rollback() -> UniqueWithConflictClauseBuilder {
            return UniqueWithConflictClauseBuilder(conflictClause: .rollback)
        }
        
        public func abort() -> UniqueWithConflictClauseBuilder {
            return UniqueWithConflictClauseBuilder(conflictClause: .abort)
        }
        
        public func fail() -> UniqueWithConflictClauseBuilder {
            return UniqueWithConflictClauseBuilder(conflictClause: .fail)
        }
        
        public func ignore() -> UniqueWithConflictClauseBuilder {
            return UniqueWithConflictClauseBuilder(conflictClause: .ignore)
        }
        
        public func replace() -> UniqueWithConflictClauseBuilder {
            return UniqueWithConflictClauseBuilder(conflictClause: .replace)
        }
    }
    
    public func onConflict() -> OnConflictClauseBuilder {
        return OnConflictClauseBuilder()
    }
}

public func primaryKey() -> PrimaryKeyBuilder {
    return PrimaryKeyBuilder()
}

public func notNull() -> NotNullBuilder {
    return NotNullBuilder()
}

public func unique() -> UniqueBuilder {
    return UniqueBuilder()
}
