import XCTest
@testable import SQLiteORM

class StorageTests: XCTestCase {
    struct User: Initializable, Equatable {
        var id = 0
        var name = ""

        static func == (lhs: Self, rhs: Self) -> Bool {
            return lhs.id == rhs.id && lhs.name == rhs.name
        }
    }

    struct Visit: Initializable {
        var id = 0
    }

    var storage: Storage!
    var apiProvider: SQLiteApiProviderMock!

    override func setUpWithError() throws {
        self.storage = try Storage(filename: "",
                                   tables: Table<User>(name: "users",
                                                       columns:
                                                        Column(name: "id", keyPath: \User.id, constraints: primaryKey(), notNull()),
                                                        Column(name: "name", keyPath: \User.name, constraints: notNull())))
    }

    override func tearDownWithError() throws {
        self.storage = nil
    }

    func testEnumerated() throws {
        try testCase(#function, routine: {
            let storage = try Storage(filename: "",
                                      tables: Table<User>(name: "users",
                                                          columns:
                                                           Column(name: "id", keyPath: \User.id, constraints: primaryKey(), notNull()),
                                                           Column(name: "name", keyPath: \User.name, constraints: notNull())))
            try storage.syncSchema(preserve: false)

            var expected = [User]()
            var users = [User]()

            let user1 = User(id: 1, name: "The Weeknd")
            let user2 = User(id: 2, name: "Post Malone")
            expected.append(user1)
            expected.append(user2)
            try storage.replace(user1)
            try storage.replace(user2)

            /*try section("enumerated", routine: {
                for userResult in storage.enumerated(User.self) {
                    switch userResult {
                    case .success(let user):
                        users.append(user)
                    case .failure(let error):
                        throw error
                    }
                }
            })*/
            try section("forEach", routine: {
                try storage.forEach(User.self) {
                    users.append($0)
                }
            })
            XCTAssert(compareUnordered(users, expected))
        })
    }

    func testColumnNameWithReservedKeyword() throws {
        struct Object: Initializable {
            var id = 0
            var order = 0
        }
        let storage = try Storage(filename: "", tables: Table<Object>(name: "objects",
                                                                      columns:
                                                                        Column(name: "id", keyPath: \Object.id),
                                                                        Column(name: "order", keyPath: \Object.order)))
        try storage.syncSchema(preserve: true)
    }

    func testFilename() throws {
        struct TestCase {
            let filename: String
        }
        let testCases = [
            TestCase(filename: "ototo"),
            TestCase(filename: ""),
            TestCase(filename: ":memory:"),
            TestCase(filename: "db.sqlite"),
            TestCase(filename: "company.db")
        ]
        for testCase in testCases {
            let apiProvider = SQLiteApiProviderMock()
            apiProvider.forwardsCalls = true
            let storage = try Storage(filename: testCase.filename, apiProvider: apiProvider, tables: [])
            XCTAssertEqual(storage.filename, testCase.filename)
        }
    }

    func testCtorDtor() throws {
        try testCase(#function, routine: {
            let apiProvider = SQLiteApiProviderMock()
            apiProvider.forwardsCalls = true
            var expectedCtorCalls = [SQLiteApiProviderMock.Call]()
            var expectedDtorCalls = [SQLiteApiProviderMock.Call]()
            var ctorCalls = [SQLiteApiProviderMock.Call]()
            var dtorCalls = [SQLiteApiProviderMock.Call]()
            var filename = ""
            try section("file", routine: {
                filename = "db.sqlite"
                expectedCtorCalls = []
                expectedDtorCalls = []
            })
            try section("memory", routine: {
                try section("empty filename", routine: {
                    filename = ""
                })
                try section(":memory: filename", routine: {
                    filename = ":memory:"
                })
                expectedCtorCalls = [.init(id: 0, callType: .sqlite3Open(filename, .ignore))]
                expectedDtorCalls = [.init(id: 0, callType: .sqlite3Close(.ignore))]
            })
            var storage: Storage? = try Storage(filename: filename,
                                                apiProvider: apiProvider,
                                                tables: [])
            _ = storage
            ctorCalls = apiProvider.calls
            apiProvider.resetCalls()
            storage = nil
            dtorCalls = apiProvider.calls
            XCTAssertEqual(expectedCtorCalls, ctorCalls)
            XCTAssertEqual(expectedDtorCalls, dtorCalls)
        })
    }

    func testDelete() throws {
        try self.storage.syncSchema(preserve: true)

        let bebeRexha = User(id: 1, name: "Bebe Rexha")
        let arianaGrande = User(id: 2, name: "Ariana Grande")
        try self.storage.replace(bebeRexha)
        try self.storage.replace(arianaGrande)
        var allUsers: [User] = try self.storage.getAll()
        XCTAssert(compareUnordered(allUsers, [bebeRexha, arianaGrande]))

        try self.storage.delete(bebeRexha)
        allUsers = try self.storage.getAll()
        XCTAssert(allUsers == [arianaGrande])
    }

    func testTableExists() throws {
        let apiProvider = SQLiteApiProviderMock()
        apiProvider.forwardsCalls = true
        let storage = try Storage(filename: "",
                                  apiProvider: apiProvider,
                                  tables: [Table<User>(name: "users",
                                                       columns:
                                                        Column(name: "id", keyPath: \User.id, constraints: primaryKey(), notNull()),
                                                        Column(name: "name", keyPath: \User.name, constraints: notNull()))])
        apiProvider.resetCalls()
        XCTAssertFalse(try storage.tableExists(with: "users"))
        XCTAssertEqual(apiProvider.calls, [
            .init(id: 0, callType: .sqlite3PrepareV2(.ignore, "SELECT COUNT(*) FROM sqlite_master WHERE type = \'table\' AND name = \'users\'", -1, .ignore, nil)),
            .init(id: 1, callType: .sqlite3Step(.ignore)),
            .init(id: 2, callType: .sqlite3ColumnInt(.ignore, 0)),
            .init(id: 3, callType: .sqlite3Step(.ignore)),
            .init(id: 4, callType: .sqlite3Finalize(.ignore))
        ])

        apiProvider.resetCalls()
        XCTAssertFalse(try storage.tableExists(with: "visits"))
        XCTAssertEqual(apiProvider.calls, [
            .init(id: 0, callType: .sqlite3PrepareV2(.ignore, "SELECT COUNT(*) FROM sqlite_master WHERE type = \'table\' AND name = \'visits\'", -1, .ignore, nil)),
            .init(id: 1, callType: .sqlite3Step(.ignore)),
            .init(id: 2, callType: .sqlite3ColumnInt(.ignore, 0)),
            .init(id: 3, callType: .sqlite3Step(.ignore)),
            .init(id: 4, callType: .sqlite3Finalize(.ignore))
        ])

        try storage.syncSchema(preserve: true)

        apiProvider.resetCalls()
        XCTAssertTrue(try storage.tableExists(with: "users"))
        XCTAssertEqual(apiProvider.calls, [
            .init(id: 0, callType: .sqlite3PrepareV2(.ignore, "SELECT COUNT(*) FROM sqlite_master WHERE type = \'table\' AND name = \'users\'", -1, .ignore, nil)),
            .init(id: 1, callType: .sqlite3Step(.ignore)),
            .init(id: 2, callType: .sqlite3ColumnInt(.ignore, 0)),
            .init(id: 3, callType: .sqlite3Step(.ignore)),
            .init(id: 4, callType: .sqlite3Finalize(.ignore))
        ])

        apiProvider.resetCalls()
        XCTAssertFalse(try storage.tableExists(with: "visits"))
        XCTAssertEqual(apiProvider.calls, [
            .init(id: 0, callType: .sqlite3PrepareV2(.ignore, "SELECT COUNT(*) FROM sqlite_master WHERE type = \'table\' AND name = \'visits\'", -1, .ignore, nil)),
            .init(id: 1, callType: .sqlite3Step(.ignore)),
            .init(id: 2, callType: .sqlite3ColumnInt(.ignore, 0)),
            .init(id: 3, callType: .sqlite3Step(.ignore)),
            .init(id: 4, callType: .sqlite3Finalize(.ignore))
        ])
    }
}
