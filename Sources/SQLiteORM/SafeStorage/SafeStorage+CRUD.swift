import Foundation

extension SafeStorage {
    public func delete<T>(_ object: T) -> Result<Void, Error> {
        return self.deleteInternal(object)
    }
    
    public func update<T>(_ object: T) -> Result<Void, Error> {
        return self.updateInternal(object)
    }
}
