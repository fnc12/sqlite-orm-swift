import Foundation

extension Storage {

    public func beginTransaction() throws {
        let transactionResult = self.storageCore.beginTransaction()
        switch transactionResult {
        case .success(()):
            return
        case .failure(let error):
            throw error
        }
    }

    public func commit() throws {
        let commitResult = self.storageCore.commit()
        switch commitResult {
        case .success():
            return
        case .failure(let error):
            throw error
        }
    }

    public func rollback() throws {
        let rollbackResult = self.storageCore.rollback()
        switch rollbackResult {
        case .success():
            return
        case .failure(let error):
            throw error
        }
    }
}
