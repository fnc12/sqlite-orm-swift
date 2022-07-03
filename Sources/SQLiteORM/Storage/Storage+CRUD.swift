import Foundation

extension Storage {
    public func delete<T>(_ object: T) throws {
        let deleteResult = self.deleteInternal(object)
        switch deleteResult {
        case .success():
            return
        case .failure(let error):
            throw error
        }
    }

    public func update<T>(_ object: T) throws {
        let updateResult = self.updateInternal(object)
        switch updateResult {
        case .success():
            return
        case .failure(let error):
            throw error
        }
    }

    public func get<T>(id: Bindable...) throws -> T? where T: Initializable {
        let getResult: Result<T?, Error> = self.getInternal(id: id)
        switch getResult {
        case .success(let object):
            return object
        case .failure(let error):
            throw error
        }
    }

    public func insert<T>(_ object: T) throws -> Int64 {
        let insertResult = self.insertInternal(object)
        switch insertResult {
        case .success(let code):
            return code
        case .failure(let error):
            throw error
        }
    }

    public func replace<T>(_ object: T) throws {
        let replaceResult = self.replaceInternal(object)
        switch replaceResult {
        case .success():
            return
        case .failure(let error):
            throw error
        }
    }
}
