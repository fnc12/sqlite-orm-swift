import Foundation

extension Storage {
    
    public func select<R1, R2, R3>(_ expression1: Expression,
                                   _ expression2: Expression,
                                   _ expression3: Expression,
                                   _ constraints: SelectConstraint...) throws -> [(R1, R2, R3)] where R1: ConstructableFromSQLiteValue, R2: ConstructableFromSQLiteValue, R3: ConstructableFromSQLiteValue {
        let selectResult: Result<[(R1, R2, R3)], Error> = self.storageCore.select(expression1, expression2, expression3, constraints)
        switch selectResult {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        }
    }
    
    public func select<R1, R2>(_ expression1: Expression,
                               _ expression2: Expression,
                               _ constraints: SelectConstraint...) throws -> [(R1, R2)] where R1: ConstructableFromSQLiteValue, R2: ConstructableFromSQLiteValue {
        let selectResult: Result<[(R1, R2)], Error> = self.storageCore.select(expression1, expression2, constraints)
        switch selectResult {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        }
    }

    public func select<R>(_ expression: Expression,
                          _ constraints: SelectConstraint...) throws -> [R] where R: ConstructableFromSQLiteValue {
        let selectResult: Result<[R], Error> = self.storageCore.select(expression, constraints)
        switch selectResult {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        }
    }

    public func update<T>(all of: T.Type, _ set: AssignList, _ constraints: SelectConstraint...) throws {
        switch self.storageCore.update(all: T.self, set, constraints) {
        case .success():
            return
        case .failure(let error):
            throw error
        }
    }

    public func delete<T>(all of: T.Type, _ constraints: SelectConstraint...) throws {
        switch self.storageCore.delete(all: T.self, constraints) {
        case .success():
            return
        case .failure(let error):
            throw error
        }
    }
    
    public func getAll<T>(all of: T.Type, _ constraints: SelectConstraint...) throws -> [T] where T: Initializable {
        let getAllResult: Result<[T], Error> = self.storageCore.getAll(all: T.self, constraints)
        switch getAllResult {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        }
    }

    public func getAll<T>(_ constraints: SelectConstraint...) throws -> [T] where T: Initializable {
        let getAllResult: Result<[T], Error> = self.storageCore.getAll(constraints)
        switch getAllResult {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        }
    }
}
