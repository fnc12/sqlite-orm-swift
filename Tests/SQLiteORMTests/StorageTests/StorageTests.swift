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
        self.apiProvider = .init()
    }

    override func tearDownWithError() throws {
        self.apiProvider = nil
        self.storage = nil
    }
    
    func testIterate() throws {
        try testCase(#function, routine: {
            let storage = try Storage(filename: "",
                                      tables: Table<User>(name: "users",
                                                          columns:
                                                           Column(name: "id", keyPath: \User.id, constraints: primaryKey(), notNull()),
                                                           Column(name: "name", keyPath: \User.name, constraints: notNull())))
            try storage.syncSchema(preserve: false)
            
            var expected = [User]()
            var users = [User]()
            try section("empty", routine: {
                //..
            })
            try section("one user", routine: {
                let user = User(id: 1, name: "The Weeknd")
                expected.append(user)
                try storage.replace(user)
            })
            try section("two user", routine: {
                let user1 = User(id: 1, name: "The Weeknd")
                let user2 = User(id: 2, name: "Post Malone")
                expected.append(user1)
                expected.append(user2)
                try storage.replace(user1)
                try storage.replace(user2)
            })
            for user in storage.iterate(all: User.self) {
                users.append(user)
            }
            XCTAssert(compareUnordered(users, expected))
        })
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

    func testGet() throws {
        do {
            let _: User? = try storage.get(id: 1)
            XCTAssert(false)
        } catch SQLiteORM.Error.sqliteError(_, _) {
            XCTAssert(true)
        } catch {
            XCTAssert(false)
        }
        try storage.syncSchema(preserve: true)

        try storage.replace(User(id: 1, name: "Bebe Rexha"))
        let bebeRexhaMaybe: User? = try storage.get(id: 1)
        XCTAssertEqual(bebeRexhaMaybe, User(id: 1, name: "Bebe Rexha"))

        for id in 2..<10 {
            let user: User? = try storage.get(id: id)
            XCTAssert(user == nil)
        }
    }

    func testUpdate() throws {
        try storage.syncSchema(preserve: true)
        var bebeRexha = User(id: 1, name: "Bebe Rexha")
        try storage.replace(bebeRexha)
        var allUsers: [User] = try storage.getAll()
        XCTAssertEqual(allUsers, [bebeRexha])

        bebeRexha.name = "Ariana Grande"
        try storage.update(bebeRexha)
        allUsers = try storage.getAll()
        XCTAssertEqual(allUsers, [bebeRexha])
    }

    func testDelete() throws {
        try storage.syncSchema(preserve: true)

        let bebeRexha = User(id: 1, name: "Bebe Rexha")
        let arianaGrande = User(id: 2, name: "Ariana Grande")
        try storage.replace(bebeRexha)
        try storage.replace(arianaGrande)
        var allUsers: [User] = try storage.getAll()
        XCTAssert(compareUnordered(allUsers, [bebeRexha, arianaGrande]))

        try storage.delete(bebeRexha)
        allUsers = try storage.getAll()
        XCTAssert(allUsers == [arianaGrande])
    }

    func testTableExists() throws {
        XCTAssertFalse(try storage.tableExists(with: "users"))
        XCTAssertFalse(try storage.tableExists(with: "visits"))

        try storage.syncSchema(preserve: true)

        XCTAssertTrue(try storage.tableExists(with: "users"))
        XCTAssertFalse(try storage.tableExists(with: "visits"))
    }

    func testReplace() throws {
        try storage.syncSchema(preserve: true)

        var allUsers: [User] = try storage.getAll()
        XCTAssertTrue(allUsers.isEmpty)

        let bebeRexha = User(id: 1, name: "Bebe Rexha")
        try storage.replace(bebeRexha)

        allUsers = try storage.getAll()
        XCTAssertEqual(allUsers, [bebeRexha])

        let arianaGrande = User(id: 2, name: "Ariana Grande")
        try storage.replace(arianaGrande)

        allUsers = try storage.getAll()
        XCTAssert(compareUnordered(allUsers, [bebeRexha, arianaGrande]))
    }
}
