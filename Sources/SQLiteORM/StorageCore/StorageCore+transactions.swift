import Foundation

extension StorageCore {
    func beginTransaction() -> Result<Void, Error> {
        let incrementResult = self.connection.increment()
        switch incrementResult {
        case .success():
            let connectionRefResult = self.connection.createConnectionRef()
            switch connectionRefResult {
            case .success(let connectionRef):
                let execResult = connectionRef.exec(sql: "BEGIN TRANSACTION")
                switch execResult {
                case .success(()):
                    return .success(())
                case .failure(let error):
                    return .failure(error)
                }
            case .failure(let error):
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func commit() -> Result<Void, Error> {
        let connectionRefResult = self.connection.createConnectionRef()
        switch connectionRefResult {
        case .success(let connectionRef):
            let execResult = connectionRef.exec(sql: "COMMIT")
            switch execResult {
            case .success():
                let decrementResult = self.connection.decrement()
                switch decrementResult {
                case .success():
                    return .success(())
                case .failure(let error):
                    return .failure(error)
                }
            case .failure(let error):
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func rollback() -> Result<Void, Error> {
        let connectionRefResult = self.connection.createConnectionRef()
        switch connectionRefResult {
        case .success(let connectionRef):
            let execResult = connectionRef.exec(sql: "ROLLBACK")
            switch execResult {
            case .success():
                let decrementResult = self.connection.decrement()
                switch decrementResult {
                case .success():
                    return .success(())
                case .failure(let error):
                    return .failure(error)
                }
            case .failure(let error):
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
}
