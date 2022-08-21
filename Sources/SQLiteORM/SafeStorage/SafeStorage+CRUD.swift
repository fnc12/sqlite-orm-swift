import Foundation

extension SafeStorage {
    public func delete<T>(_ object: T) -> Result<Void, Error> {
        return self.storageCore.deleteInternal(object)
    }
    
    public func update<T>(_ object: T) -> Result<Void, Error> {
        return self.storageCore.updateInternal(object)
    }
    
    public func get<T>(of: T.Type, id: Bindable...) -> Result<T?, Error> where T: Initializable {
        return self.storageCore.getInternal(id: id)
    }
    
    public func insert<T>(_ object: T) -> Result<Int64, Error> {
        return self.storageCore.insertInternal(object)
    }
    
    public func replace<T>(_ object: T) -> Result<Void, Error> {
        return self.storageCore.replaceInternal(object)
    }
}
