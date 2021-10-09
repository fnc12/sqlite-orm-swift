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
    
    func testFilename() throws {
        struct TestCase {
            let filename: String
        }
        let testCases = [
            TestCase(filename: "ototo"),
            TestCase(filename: ""),
            TestCase(filename: ":memory:"),
            TestCase(filename: "db.sqlite"),
            TestCase(filename: "company.db"),
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
    
    func testGetAll() throws {
        try testCase(#function, routine: {
            let apiProvider = SQLiteApiProviderMock()
            apiProvider.forwardsCalls = true
            let createStorage = { (filename: String) throws -> Storage in
                let storage = try Storage(filename: filename,
                                          apiProvider: apiProvider,
                                          tables: [Table<User>(name: "users",
                                                               columns:
                                                                Column(name: "id", keyPath: \User.id, constraints: primaryKey(), notNull()),
                                                               Column(name: "name", keyPath: \User.name, constraints: notNull()))])
                try storage.syncSchema(preserve: false)
                return storage
            }
            try section("error", routine: {
                let storage = try createStorage("")
                do {
                    let visits: [Visit] = try storage.getAll()
                    XCTAssert(false)
                    _ = visits
                }catch SQLiteORM.Error.typeIsNotMapped {
                    XCTAssert(true)
                }catch{
                    XCTAssert(false)
                }
            })
            try section("no error", routine: {
                var inMemory = false
                try section("file", routine: {
                    inMemory = false
                })
                try section("memory", routine: {
                    inMemory = true
                })
                let filename = inMemory ? "" : "db.sqlite"
                if !inMemory {
                    remove(filename)
                }
                let storage = try createStorage(filename)
                var expectedCalls = [SQLiteApiProviderMock.Call]()
                if inMemory {
                    let db = storage.connection.dbMaybe!
                    expectedCalls = [
                        .init(id: 0, callType: .sqlite3PrepareV2(.value(db), "SELECT * FROM users", -1, .ignore, nil)),
                        .init(id: 1, callType: .sqlite3Step(.ignore)),
                        .init(id: 2, callType: .sqlite3ColumnCount(.ignore)),
                        .init(id: 3, callType: .sqlite3Finalize(.ignore)),
                    ]
                }else{
                    expectedCalls = [
                        .init(id: 0, callType: .sqlite3Open(filename, .ignore)),
                        .init(id: 1, callType: .sqlite3PrepareV2(.ignore, "SELECT * FROM users", -1, .ignore, nil)),
                        .init(id: 2, callType: .sqlite3Step(.ignore)),
                        .init(id: 3, callType: .sqlite3ColumnCount(.ignore)),
                        .init(id: 4, callType: .sqlite3Finalize(.ignore)),
                        .init(id: 5, callType: .sqlite3Close(.ignore)),
                    ]
                }
                apiProvider.resetCalls()
                var users: [User] = try storage.getAll()
                XCTAssertEqual(apiProvider.calls, expectedCalls)
                XCTAssertEqual(users, [])
                
                try storage.replace(User(id: 3, name: "Ted"))
                if inMemory {
                    let db = storage.connection.dbMaybe!
                    expectedCalls = [
                        .init(id: 0, callType: .sqlite3PrepareV2(.value(db), "SELECT * FROM users", -1, .ignore, nil)),
                        .init(id: 1, callType: .sqlite3Step(.ignore)),
                        .init(id: 2, callType: .sqlite3ColumnCount(.ignore)),
                        .init(id: 3, callType: .sqlite3ColumnInt(.ignore, 0)),
                        .init(id: 4, callType: .sqlite3ColumnText(.ignore, 1)),
                        .init(id: 5, callType: .sqlite3Step(.ignore)),
                        .init(id: 6, callType: .sqlite3ColumnCount(.ignore)),
                        .init(id: 7, callType: .sqlite3Finalize(.ignore)),
                    ]
                }else{
                    expectedCalls = [
                        .init(id: 0, callType: .sqlite3Open(filename, .ignore)),
                        .init(id: 1, callType: .sqlite3PrepareV2(.ignore, "SELECT * FROM users", -1, .ignore, nil)),
                        .init(id: 2, callType: .sqlite3Step(.ignore)),
                        .init(id: 3, callType: .sqlite3ColumnCount(.ignore)),
                        .init(id: 4, callType: .sqlite3ColumnInt(.ignore, 0)),
                        .init(id: 5, callType: .sqlite3ColumnText(.ignore, 1)),
                        .init(id: 6, callType: .sqlite3Step(.ignore)),
                        .init(id: 7, callType: .sqlite3ColumnCount(.ignore)),
                        .init(id: 8, callType: .sqlite3Finalize(.ignore)),
                        .init(id: 9, callType: .sqlite3Close(.ignore)),
                    ]
                }
                apiProvider.resetCalls()
                users = try storage.getAll()
                XCTAssertEqual(apiProvider.calls, expectedCalls)
                XCTAssertEqual(users, [User(id: 3, name: "Ted")])
            })
        })
    }
    
    func testGet() throws {
        do {
            let _: User? = try storage.get(id: 1)
            XCTAssert(false)
        }catch SQLiteORM.Error.sqliteError(_, _) {
            XCTAssert(true)
        }catch{
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
            }else{
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
                    .init(id: 1, callType: .sqlite3PrepareV2(.ignore, "INSERT INTO users (name) VALUES (?)", -1, .ignore, nil)),
                    .init(id: 2, callType: .sqlite3BindText(.ignore, 1, "Bebe Rexha", -1, apiProvider.SQLITE_TRANSIENT)),
                    .init(id: 3, callType: .sqlite3Step(.ignore)),
                    .init(id: 4, callType: .sqlite3LastInsertRowid(.ignore)),
                    .init(id: 5, callType: .sqlite3Finalize(.ignore)),
                    .init(id: 6, callType: .sqlite3Close(.ignore)),
                ]
            }else{
                let db = storage.connection.dbMaybe!
                expectedCalls = [
                    .init(id: 0, callType: .sqlite3PrepareV2(.value(db), "INSERT INTO users (name) VALUES (?)", -1, .ignore, nil)),
                    .init(id: 1, callType: .sqlite3BindText(.ignore, 1, "Bebe Rexha", -1, apiProvider.SQLITE_TRANSIENT)),
                    .init(id: 2, callType: .sqlite3Step(.ignore)),
                    .init(id: 3, callType: .sqlite3LastInsertRowid(.ignore)),
                    .init(id: 4, callType: .sqlite3Finalize(.ignore)),
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
                    .init(id: 1, callType: .sqlite3PrepareV2(.ignore, "INSERT INTO users (name) VALUES (?)", -1, .ignore, nil)),
                    .init(id: 2, callType: .sqlite3BindText(.ignore, 1, "Ariana Grande", -1, apiProvider.SQLITE_TRANSIENT)),
                    .init(id: 3, callType: .sqlite3Step(.ignore)),
                    .init(id: 4, callType: .sqlite3LastInsertRowid(.ignore)),
                    .init(id: 5, callType: .sqlite3Finalize(.ignore)),
                    .init(id: 6, callType: .sqlite3Close(.ignore)),
                ]
            }else{
                let db = storage.connection.dbMaybe!
                expectedCalls = [
                    .init(id: 0, callType: .sqlite3PrepareV2(.value(db), "INSERT INTO users (name) VALUES (?)", -1, .ignore, nil)),
                    .init(id: 1, callType: .sqlite3BindText(.ignore, 1, "Ariana Grande", -1, apiProvider.SQLITE_TRANSIENT)),
                    .init(id: 2, callType: .sqlite3Step(.ignore)),
                    .init(id: 3, callType: .sqlite3LastInsertRowid(.ignore)),
                    .init(id: 4, callType: .sqlite3Finalize(.ignore)),
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
