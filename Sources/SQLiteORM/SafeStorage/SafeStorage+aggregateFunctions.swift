import Foundation

extension SafeStorage {
    public func total<T, R>(_ columnKeyPath: KeyPath<T, R>, _ constraints: SelectConstraint...) -> Result<Double, Error> {
        return self.storageCore.total(columnKeyPath, constraints)
    }

    public func sum<T, R>(_ columnKeyPath: KeyPath<T, R>, _ constraints: SelectConstraint...) -> Result<Double?, Error> {
        return self.storageCore.sum(columnKeyPath, constraints)
    }

    public func min<T, F>(_ columnKeyPath: KeyPath<T, F?>,
                          _ constraints: SelectConstraint...) -> Result<F?, Error> where F: ConstructableFromSQLiteValue {
        return self.storageCore.min(columnKeyPath, constraints)
    }

    public func min<T, F>(_ columnKeyPath: KeyPath<T, F>,
                          _ constraints: SelectConstraint...) -> Result<F?, Error> where F: ConstructableFromSQLiteValue {
        return self.storageCore.min(columnKeyPath, constraints)
    }

    public func max<T, F>(_ columnKeyPath: KeyPath<T, F?>,
                          _ constraints: SelectConstraint...) -> Result<F?, Error> where F: ConstructableFromSQLiteValue {
        return self.storageCore.max(columnKeyPath, constraints)
    }

    public func max<T, F>(_ columnKeyPath: KeyPath<T, F>,
                          _ constraints: SelectConstraint...) -> Result<F?, Error> where F: ConstructableFromSQLiteValue {
        return self.storageCore.max(columnKeyPath, constraints)
    }

    public func groupConcat<T, F>(_ columnKeyPath: KeyPath<T, F>,
                                  separator: String,
                                  _ constraints: SelectConstraint...) -> Result<String?, Error> {
        return self.storageCore.groupConcat(columnKeyPath, separator: separator, constraints)
    }

    public func groupConcat<T, F>(_ columnKeyPath: KeyPath<T, F>, _ constraints: SelectConstraint...) -> Result<String?, Error> {
        return self.storageCore.groupConcat(columnKeyPath, constraints)
    }

    public func count<T, F>(_ columnKeyPath: KeyPath<T, F>, _ constraints: SelectConstraint...) -> Result<Int, Error> {
        return self.storageCore.count(columnKeyPath, constraints)
    }

    public func count<T>(all of: T.Type, _ constraints: SelectConstraint...) -> Result<Int, Error> {
        return self.storageCore.count(all: T.self, constraints)
    }

    public func avg<T, F>(_ columnKeyPath: KeyPath<T, F>, _ constraints: SelectConstraint...) -> Result<Double?, Error> {
        return self.storageCore.avg(columnKeyPath, constraints)
    }
}
