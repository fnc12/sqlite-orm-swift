import XCTest
@testable import SQLiteORM

class StorageTransactionTests: XCTestCase {
    struct User: Initializable, Equatable {
        var id = 0
        var name = ""
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            return lhs.id == rhs.id && lhs.name == rhs.name
        }
    }
    
    var storage: Storage!
    let filename = ""
    var apiProvider: SQLiteApiProviderMock!
    var connectionHolderMock: ConnectionHolderMock!
    let db = OpaquePointer(bitPattern: 1)!
    
    override func setUpWithError() throws {
        self.apiProvider = .init()
        self.connectionHolderMock = .init(dbMaybe: self.db, apiProvider: self.apiProvider, filename: self.filename)
        self.storage = try .init(filename: self.filename,
                                 apiProvider: self.apiProvider,
                                 connection: self.connectionHolderMock,
                                 tables: [Table<User>(name: "users",
                                                      columns:
                                                        Column(name: "id", keyPath: \User.id, constraints: primaryKey(), notNull()),
                                                        Column(name: "name", keyPath: \User.name, constraints: notNull()))])
    }
    
    override func tearDownWithError() throws {
        self.storage = nil
        self.connectionHolderMock = nil
        self.apiProvider = nil
    }
    
    func testRollback() throws {
        self.connectionHolderMock.resetCalls()
        try self.storage.rollback()
        XCTAssertEqual(self.connectionHolderMock.calls, [ConnectionHolderMock.Call(id: 0, callType: .increment),
                                                         ConnectionHolderMock.Call(id: 1, callType: .decrement),
                                                         ConnectionHolderMock.Call(id: 2, callType: .decrementUnsafe)])
        XCTAssertEqual(self.apiProvider.calls, [SQLiteApiProviderMock.Call(id: 0, callType: .sqlite3Exec(self.db, "ROLLBACK", nil, nil, nil))])
    }
    
    func testCommit() throws {
        self.connectionHolderMock.resetCalls()
        try self.storage.commit()
        XCTAssertEqual(self.connectionHolderMock.calls, [ConnectionHolderMock.Call(id: 0, callType: .increment),
                                                         ConnectionHolderMock.Call(id: 1, callType: .decrement),
                                                         ConnectionHolderMock.Call(id: 2, callType: .decrementUnsafe)])
        XCTAssertEqual(self.apiProvider.calls, [SQLiteApiProviderMock.Call(id: 0, callType: .sqlite3Exec(self.db, "COMMIT", nil, nil, nil))])
    }
    
    func testBeginTransaction() throws {
        self.connectionHolderMock.resetCalls()
        try self.storage.beginTransaction()
        XCTAssertEqual(self.connectionHolderMock.calls, [ConnectionHolderMock.Call(id: 0, callType: .increment),
                                                         ConnectionHolderMock.Call(id: 1, callType: .increment),
                                                         ConnectionHolderMock.Call(id: 2, callType: .decrementUnsafe)])
        XCTAssertEqual(self.apiProvider.calls, [SQLiteApiProviderMock.Call(id: 0, callType: .sqlite3Exec(self.db, "BEGIN TRANSACTION", nil, nil, nil))])
    }
}
