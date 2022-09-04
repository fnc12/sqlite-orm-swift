import Foundation

extension SafeStorage {
    
    public func tableExists(with name: String) -> Result<Bool, Error> {
        return self.storageCore.tableExists(with: name)
    }

    @discardableResult
    public func syncSchema(preserve: Bool) -> Result<[String: SyncSchemaResult], Error> {
        return self.storageCore.syncSchema(preserve: preserve)
    }
}
