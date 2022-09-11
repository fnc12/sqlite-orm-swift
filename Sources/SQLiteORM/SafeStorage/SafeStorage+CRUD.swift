import Foundation

extension SafeStorage {
    public func delete<T>(_ object: T) -> Result<Void, Error> {
        return self.storageCore.delete(object)
    }
    
    public func update<T>(_ object: T) -> Result<Void, Error> {
        return self.storageCore.update(object)
    }
    
    public func get<T>(of: T.Type, id: Bindable...) -> Result<T?, Error> where T: Initializable {
        return self.storageCore.get(id: id)
    }
    
    public func insert<T>(_ object: T) -> Result<Int64, Error> {
        return self.storageCore.insert(object)
    }
    
    public func replace<T>(_ object: T) -> Result<Void, Error> {
        return self.storageCore.replace(object)
    }
}
