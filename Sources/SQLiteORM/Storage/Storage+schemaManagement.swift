import Foundation

extension Storage {

    public func tableExists(with name: String) throws -> Bool {
        switch self.storageCore.tableExists(with: name) {
        case .success(let exists):
            return exists
        case .failure(let error):
            throw error
        }
    }

    @discardableResult
    public func syncSchema(preserve: Bool) throws -> [String: SyncSchemaResult] {
        switch self.storageCore.syncSchema(preserve: preserve) {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        }
    }
}
