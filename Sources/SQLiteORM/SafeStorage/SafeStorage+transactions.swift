import Foundation

extension SafeStorage {
    
    public func beginTransaction() -> Result<Void, Error> {
        return self.storageCore.beginTransaction()
    }

    public func commit() -> Result<Void, Error> {
        return self.storageCore.commit()
    }

    public func rollback() -> Result<Void, Error> {
        return self.storageCore.rollback()
    }
}
