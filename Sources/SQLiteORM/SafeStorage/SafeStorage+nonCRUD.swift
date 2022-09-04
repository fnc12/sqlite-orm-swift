import Foundation

extension SafeStorage {
    public func select<R1, R2, R3>(_ expression1: Expression,
                                   _ expression2: Expression,
                                   _ expression3: Expression,
                                   _ constraints: SelectConstraint...) -> Result<[(R1, R2, R3)], Error> where R1: ConstructableFromSQLiteValue, R2: ConstructableFromSQLiteValue, R3: ConstructableFromSQLiteValue {
        return self.storageCore.select(expression1, expression2, expression3, constraints)
    }
    
    public func select<R1, R2>(_ expression1: Expression,
                               _ expression2: Expression,
                               _ constraints: SelectConstraint...) -> Result<[(R1, R2)], Error> where R1: ConstructableFromSQLiteValue, R2: ConstructableFromSQLiteValue {
        return self.storageCore.select(expression1, expression2, constraints)
    }

    public func select<R>(_ expression: Expression,
                          _ constraints: SelectConstraint...) -> Result<[R], Error> where R: ConstructableFromSQLiteValue {
        return self.storageCore.select(expression, constraints)
    }

    public func update<T>(all of: T.Type, _ set: AssignList, _ constraints: SelectConstraint...) -> Result<Void, Error> {
        return self.storageCore.update(all: T.self, set, constraints)
    }

    public func delete<T>(all of: T.Type, _ constraints: SelectConstraint...) -> Result<Void, Error> {
        return self.storageCore.delete(all: T.self, constraints)
    }
    
    public func getAll<T>(all of: T.Type, _ constraints: SelectConstraint...) -> Result<[T], Error> where T: Initializable {
        return self.storageCore.getAll(all: T.self, constraints)
    }

    public func getAll<T>(_ constraints: SelectConstraint...) -> Result<[T], Error> where T: Initializable {
        return self.storageCore.getAll(constraints)
    }
}
