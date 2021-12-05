import XCTest
@testable import SQLiteORM

class StorageCrudTests: XCTestCase {
    struct User: Initializable, Equatable {
        var id = 0
        var name = ""

        static func == (lhs: Self, rhs: Self) -> Bool {
            return lhs.id == rhs.id && lhs.name == rhs.name
        }
    }

    func testInsert() throws {
        try testCase(#function, routine: {
            let apiProvider = SQLiteApiProviderMock()
            apiProvider.forwardsCalls = true
            var inMemory = false
            try section("in memory", routine: {
                inMemory = true
            })
            try section("in file", routine: {
                inMemory = false
            })

            let filename: String
            if inMemory {
                filename = ""
            } else {
                filename = "test_storage.sqlite"
                remove(filename)
            }
            let storage = try Storage(filename: filename,
                                      apiProvider: apiProvider,
                                      tables: [Table<User>(name: "users",
                                                           columns:
                                                            Column(name: "id", keyPath: \User.id, constraints: primaryKey(), notNull()),
                                                            Column(name: "name", keyPath: \User.name, constraints: notNull()))])
            try storage.syncSchema(preserve: false)

            var bebeRexha = User(id: 0, name: "Bebe Rexha")
            apiProvider.resetCalls()
            let bebeRexhaId = try storage.insert(bebeRexha)
            XCTAssertEqual(bebeRexhaId, 1)
            var expectedCalls = [SQLiteApiProviderMock.Call]()
            if !inMemory {
                expectedCalls = [
                    .init(id: 0, callType: .sqlite3Open(filename, .ignore)),
                    .init(id: 1, callType: .sqlite3PrepareV2(.ignore, "INSERT INTO users (\"name\") VALUES (?)", -1, .ignore, nil)),
                    .init(id: 2, callType: .sqlite3BindText(.ignore, 1, "Bebe Rexha", -1, apiProvider.SQLITE_TRANSIENT)),
                    .init(id: 3, callType: .sqlite3Step(.ignore)),
                    .init(id: 4, callType: .sqlite3LastInsertRowid(.ignore)),
                    .init(id: 5, callType: .sqlite3Finalize(.ignore)),
                    .init(id: 6, callType: .sqlite3Close(.ignore))
                ]
            } else {
                let db = storage.connection.dbMaybe!
                expectedCalls = [
                    .init(id: 0, callType: .sqlite3PrepareV2(.value(db), "INSERT INTO users (\"name\") VALUES (?)", -1, .ignore, nil)),
                    .init(id: 1, callType: .sqlite3BindText(.ignore, 1, "Bebe Rexha", -1, apiProvider.SQLITE_TRANSIENT)),
                    .init(id: 2, callType: .sqlite3Step(.ignore)),
                    .init(id: 3, callType: .sqlite3LastInsertRowid(.ignore)),
                    .init(id: 4, callType: .sqlite3Finalize(.ignore))
                ]
            }
            XCTAssertEqual(apiProvider.calls, expectedCalls)
            bebeRexha.id = Int(bebeRexhaId)

            var allUsers: [User] = try storage.getAll()
            XCTAssertEqual(allUsers, [bebeRexha])

            var arianaGrande = User(id: 0, name: "Ariana Grande")
            apiProvider.resetCalls()
            let arianaGrandeId = try storage.insert(arianaGrande)
            if !inMemory {
                expectedCalls = [
                    .init(id: 0, callType: .sqlite3Open(filename, .ignore)),
                    .init(id: 1, callType: .sqlite3PrepareV2(.ignore, "INSERT INTO users (\"name\") VALUES (?)", -1, .ignore, nil)),
                    .init(id: 2, callType: .sqlite3BindText(.ignore, 1, "Ariana Grande", -1, apiProvider.SQLITE_TRANSIENT)),
                    .init(id: 3, callType: .sqlite3Step(.ignore)),
                    .init(id: 4, callType: .sqlite3LastInsertRowid(.ignore)),
                    .init(id: 5, callType: .sqlite3Finalize(.ignore)),
                    .init(id: 6, callType: .sqlite3Close(.ignore))
                ]
            } else {
                let db = storage.connection.dbMaybe!
                expectedCalls = [
                    .init(id: 0, callType: .sqlite3PrepareV2(.value(db), "INSERT INTO users (\"name\") VALUES (?)", -1, .ignore, nil)),
                    .init(id: 1, callType: .sqlite3BindText(.ignore, 1, "Ariana Grande", -1, apiProvider.SQLITE_TRANSIENT)),
                    .init(id: 2, callType: .sqlite3Step(.ignore)),
                    .init(id: 3, callType: .sqlite3LastInsertRowid(.ignore)),
                    .init(id: 4, callType: .sqlite3Finalize(.ignore))
                ]
            }
            XCTAssertEqual(apiProvider.calls, expectedCalls)
            XCTAssertEqual(arianaGrandeId, 2)

            arianaGrande.id = Int(arianaGrandeId)

            allUsers = try storage.getAll()
            XCTAssert(compareUnordered(allUsers, [bebeRexha, arianaGrande]))
        })
    }
}
