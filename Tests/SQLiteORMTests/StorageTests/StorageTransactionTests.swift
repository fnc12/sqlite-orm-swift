import XCTest
@testable import SQLiteORM

class StorageTransactionTests: XCTestCase {
    
    func testTransactions() throws {
        struct User: Initializable, Equatable {
            var id = 0
            var name = ""
            
            static func == (lhs: Self, rhs: Self) -> Bool {
                return lhs.id == rhs.id && lhs.name == rhs.name
            }
        }
        try testCase(#function, routine: {
            let filename = ""
            let apiProvider = SQLiteApiProviderMock()
            let db = OpaquePointer(bitPattern: 1)!
            let connectionHolderMock = ConnectionHolderMock(dbMaybe: db, apiProvider: apiProvider, filename: filename)
            let storage = try Storage(filename: filename,
                                     apiProvider: apiProvider,
                                     connection: connectionHolderMock,
                                     tables: [Table<User>(name: "users",
                                                          columns:
                                                            Column(name: "id", keyPath: \User.id, constraints: primaryKey(), notNull()),
                                                            Column(name: "name", keyPath: \User.name, constraints: notNull()))])
            connectionHolderMock.resetCalls()
            var expectedConnectionHolderCalls = [ConnectionHolderMock.Call]()
            var expectedSqliteCalls = [SQLiteApiProviderMock.Call]()
            try section("rollback", routine: {
                try storage.rollback()
                expectedConnectionHolderCalls = [ConnectionHolderMock.Call(id: 0, callType: .increment),
                                                 ConnectionHolderMock.Call(id: 1, callType: .decrement),
                                                 ConnectionHolderMock.Call(id: 2, callType: .decrementUnsafe)]
                expectedSqliteCalls = [SQLiteApiProviderMock.Call(id: 0, callType: .sqlite3Exec(db, "ROLLBACK", nil, nil, nil))]
            })
            try section("commit", routine: {
                try storage.commit()
                expectedConnectionHolderCalls = [ConnectionHolderMock.Call(id: 0, callType: .increment),
                                                 ConnectionHolderMock.Call(id: 1, callType: .decrement),
                                                 ConnectionHolderMock.Call(id: 2, callType: .decrementUnsafe)]
                expectedSqliteCalls = [SQLiteApiProviderMock.Call(id: 0, callType: .sqlite3Exec(db, "COMMIT", nil, nil, nil))]
            })
            try section("begin transaction", routine: {
                try storage.beginTransaction()
                expectedConnectionHolderCalls = [ConnectionHolderMock.Call(id: 0, callType: .increment),
                                                 ConnectionHolderMock.Call(id: 1, callType: .increment),
                                                 ConnectionHolderMock.Call(id: 2, callType: .decrementUnsafe)]
                expectedSqliteCalls = [SQLiteApiProviderMock.Call(id: 0, callType: .sqlite3Exec(db, "BEGIN TRANSACTION", nil, nil, nil))]
            })
            XCTAssertEqual(connectionHolderMock.calls, expectedConnectionHolderCalls)
            XCTAssertEqual(apiProvider.calls, expectedSqliteCalls)
        })
    }
}
