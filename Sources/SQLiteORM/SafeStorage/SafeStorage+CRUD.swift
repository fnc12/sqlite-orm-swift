import Foundation

extension SafeStorage {
    public func delete<T>(_ object: T) -> Result<Void, Error> {
        return self.deleteInternal(object)
    }
    
    public func update<T>(_ object: T) -> Result<Void, Error> {
        return self.updateInternal(object)
    }
    
    public func get<T>(of: T.Type, id: Bindable...) -> Result<T?, Error> where T: Initializable {
        return self.getInternal(id: id)
    }
    
    public func insert<T>(_ object: T) -> Result<Int64, Error> {
        return self.insertInternal(object)
    }
}
