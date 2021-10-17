import Foundation

extension Storage {

    public func beginTransaction() throws {
        try self.connection.increment()
        let connectionRef = try ConnectionRef(connection: self.connection)
        try connectionRef.exec(sql: "BEGIN TRANSACTION")
    }

    public func commit() throws {
        let connectionRef = try ConnectionRef(connection: self.connection)
        try connectionRef.exec(sql: "COMMIT")
        try self.connection.decrement()
    }

    public func rollback() throws {
        let connectionRef = try ConnectionRef(connection: self.connection)
        try connectionRef.exec(sql: "ROLLBACK")
        try self.connection.decrement()
    }
}
