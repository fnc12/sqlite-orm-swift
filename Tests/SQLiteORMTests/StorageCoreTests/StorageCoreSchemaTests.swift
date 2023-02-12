import XCTest
@testable import SQLiteORM

class StorageCoreSchemaTests: XCTestCase {
    struct User: Initializable, Equatable {
        var id = 0
        var name = ""

        static func == (lhs: Self, rhs: Self) -> Bool {
            return lhs.id == rhs.id && lhs.name == rhs.name
        }
    }
    
    func testTableExists() throws {
        let apiProvider = SQLiteApiProviderMock()
        apiProvider.forwardsCalls = true
        let storageCore = try StorageCoreImpl(filename: "",
                                              apiProvider: apiProvider,
                                              tables: [
                                                Table<User>(name: "users",
                                                            elements: [
                                                                Column(name: "id", keyPath: \User.id, constraints: primaryKey(), notNull()),
                                                                Column(name: "name", keyPath: \User.name, constraints: notNull())
                                                            ])
                                              ])
        apiProvider.resetCalls()
        switch storageCore.tableExists(with: "users") {
        case .success(let value):
            XCTAssertFalse(value)
        case .failure(let error):
            throw error
        }
        XCTAssertEqual(apiProvider.calls, [
            .init(id: 0, callType: .sqlite3PrepareV2(.ignore, "SELECT COUNT(*) FROM sqlite_master WHERE type = \'table\' AND name = \'users\'", -1, .ignore, nil)),
            .init(id: 1, callType: .sqlite3Step(.ignore)),
            .init(id: 2, callType: .sqlite3ColumnInt(.ignore, 0)),
            .init(id: 3, callType: .sqlite3Step(.ignore)),
            .init(id: 4, callType: .sqlite3Finalize(.ignore))
        ])

        apiProvider.resetCalls()
        switch storageCore.tableExists(with: "visits") {
        case .success(let value):
            XCTAssertFalse(value)
        case .failure(let error):
            throw error
        }
        XCTAssertEqual(apiProvider.calls, [
            .init(id: 0, callType: .sqlite3PrepareV2(.ignore, "SELECT COUNT(*) FROM sqlite_master WHERE type = \'table\' AND name = \'visits\'", -1, .ignore, nil)),
            .init(id: 1, callType: .sqlite3Step(.ignore)),
            .init(id: 2, callType: .sqlite3ColumnInt(.ignore, 0)),
            .init(id: 3, callType: .sqlite3Step(.ignore)),
            .init(id: 4, callType: .sqlite3Finalize(.ignore))
        ])

        switch storageCore.syncSchema(preserve: true) {
        case .success(_):
            break
        case .failure(let error):
            throw error
        }

        apiProvider.resetCalls()
        switch storageCore.tableExists(with: "users") {
        case .success(let value):
            XCTAssertTrue(value)
        case .failure(let error):
            throw error
        }
        XCTAssertEqual(apiProvider.calls, [
            .init(id: 0, callType: .sqlite3PrepareV2(.ignore, "SELECT COUNT(*) FROM sqlite_master WHERE type = \'table\' AND name = \'users\'", -1, .ignore, nil)),
            .init(id: 1, callType: .sqlite3Step(.ignore)),
            .init(id: 2, callType: .sqlite3ColumnInt(.ignore, 0)),
            .init(id: 3, callType: .sqlite3Step(.ignore)),
            .init(id: 4, callType: .sqlite3Finalize(.ignore))
        ])

        apiProvider.resetCalls()
        switch storageCore.tableExists(with: "visits") {
        case .success(let value):
            XCTAssertFalse(value)
        case .failure(let error):
            throw error
        }
        XCTAssertEqual(apiProvider.calls, [
            .init(id: 0, callType: .sqlite3PrepareV2(.ignore, "SELECT COUNT(*) FROM sqlite_master WHERE type = \'table\' AND name = \'visits\'", -1, .ignore, nil)),
            .init(id: 1, callType: .sqlite3Step(.ignore)),
            .init(id: 2, callType: .sqlite3ColumnInt(.ignore, 0)),
            .init(id: 3, callType: .sqlite3Step(.ignore)),
            .init(id: 4, callType: .sqlite3Finalize(.ignore))
        ])
    }
}
