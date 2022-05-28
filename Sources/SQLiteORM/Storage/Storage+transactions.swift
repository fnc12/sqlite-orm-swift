import Foundation

extension Storage {

    public func beginTransaction() throws {
        let incrementResult = self.connection.increment()
        switch incrementResult {
        case .success():
            let connectionRef = try ConnectionRef(connection: self.connection)
            try connectionRef.exec(sql: "BEGIN TRANSACTION")
        case .failure(let error):
            throw error
        }
    }

    public func commit() throws {
        let connectionRef = try ConnectionRef(connection: self.connection)
        try connectionRef.exec(sql: "COMMIT")
        let decrementResult = self.connection.decrement()
        switch decrementResult {
        case .success():
            break
        case .failure(let error):
            throw error
        }
    }

    public func rollback() throws {
        let connectionRef = try ConnectionRef(connection: self.connection)
        try connectionRef.exec(sql: "ROLLBACK")
        let decrementResult = self.connection.decrement()
        switch decrementResult {
        case .success():
            break
        case .failure(let error):
            throw error
        }
    }
}
