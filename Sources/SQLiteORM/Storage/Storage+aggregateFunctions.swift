import Foundation

extension Storage {
    public func total<T, R>(_ columnKeyPath: KeyPath<T, R>, _ constraints: SelectConstraint...) throws -> Double {
        switch self.storageCore.total(columnKeyPath, constraints) {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        }
    }

    public func sum<T, R>(_ columnKeyPath: KeyPath<T, R>, _ constraints: SelectConstraint...) throws -> Double? {
        switch self.storageCore.sum(columnKeyPath, constraints) {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        }
    }

    public func min<T, F>(_ columnKeyPath: KeyPath<T, F?>,
                          _ constraints: SelectConstraint...) throws -> F? where F: ConstructableFromSQLiteValue {
        switch self.storageCore.min(columnKeyPath, constraints) {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        }
    }

    public func min<T, F>(_ columnKeyPath: KeyPath<T, F>, _ constraints: SelectConstraint...) throws -> F? where F: ConstructableFromSQLiteValue {
        switch self.storageCore.min(columnKeyPath, constraints) {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        }
    }

    public func max<T, F>(_ columnKeyPath: KeyPath<T, F?>,
                          _ constraints: SelectConstraint...) throws -> F? where F: ConstructableFromSQLiteValue {
        switch self.storageCore.max(columnKeyPath, constraints) {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        }
    }

    public func max<T, F>(_ columnKeyPath: KeyPath<T, F>,
                          _ constraints: SelectConstraint...) throws -> F? where F: ConstructableFromSQLiteValue {
        switch self.storageCore.max(columnKeyPath, constraints) {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        }
    }

    public func groupConcat<T, F>(_ columnKeyPath: KeyPath<T, F>, separator: String, _ constraints: SelectConstraint...) throws -> String? {
        switch self.storageCore.groupConcat(columnKeyPath, separator: separator, constraints) {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        }
    }

    public func groupConcat<T, F>(_ columnKeyPath: KeyPath<T, F>, _ constraints: SelectConstraint...) throws -> String? {
        switch self.storageCore.groupConcat(columnKeyPath, constraints) {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        }
    }

    public func count<T, F>(_ columnKeyPath: KeyPath<T, F>, _ constraints: SelectConstraint...) throws -> Int {
        switch self.storageCore.count(columnKeyPath, constraints) {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        }
    }

    public func count<T>(all of: T.Type, _ constraints: SelectConstraint...) throws -> Int {
        switch self.storageCore.count(all: T.self, constraints) {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        }
    }

    public func avg<T, F>(_ columnKeyPath: KeyPath<T, F>, _ constraints: SelectConstraint...) throws -> Double? {
        switch self.storageCore.avg(columnKeyPath, constraints) {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        }
    }
}
