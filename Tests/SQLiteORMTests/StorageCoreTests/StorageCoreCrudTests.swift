import XCTest
@testable import SQLiteORM

class StorageCoreCrudTests: XCTestCase {
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
            let storageCore = try StorageCoreImpl(filename: filename,
                                                  apiProvider: apiProvider,
                                                  tables: [Table<User>(name: "users",
                                                                       columns:
                                                                        Column(name: "id", keyPath: \User.id, constraints: primaryKey(), notNull()),
                                                                       Column(name: "name", keyPath: \User.name, constraints: notNull()))])
            switch storageCore.syncSchema(preserve: false) {
            case .success(_):
                break
            case .failure(let error):
                throw error
            }

            var bebeRexha = User(id: 0, name: "Bebe Rexha")
            apiProvider.resetCalls()
            switch storageCore.insert(bebeRexha) {
            case .success(let bebeRexhaId):
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
                    let db = storageCore.connection.dbMaybe!
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

                var getAllResults: Result<[User], Error> = storageCore.getAll([])
                switch getAllResults {
                case .success(let allUsers):
                    XCTAssertEqual(allUsers, [bebeRexha])
                case .failure(let error):
                    throw error
                }

                var arianaGrande = User(id: 0, name: "Ariana Grande")
                apiProvider.resetCalls()
                switch storageCore.insert(arianaGrande) {
                case .success(let arianaGrandeId):
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
                        let db = storageCore.connection.dbMaybe!
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

                    getAllResults = storageCore.getAll([])
                    switch getAllResults {
                    case .success(let allUsers):
                        XCTAssert(compareUnordered(allUsers, [bebeRexha, arianaGrande]))
                    case .failure(let error):
                        throw error
                    }
                case .failure(let error):
                    throw error
                }
            case .failure(let error):
                throw error
            }
        })
    }
    
    func testDelete() throws {
        let storageCore = try StorageCoreImpl(filename: "",
                                              tables: Table<User>(name: "users",
                                                                  columns:
                                                                    Column(name: "id", keyPath: \User.id, constraints: primaryKey(), notNull()),
                                                                  Column(name: "name", keyPath: \User.name, constraints: notNull())))
        switch storageCore.syncSchema(preserve: true) {
        case .success(_):
            break
        case .failure(let error):
            throw error
        }

        let bebeRexha = User(id: 1, name: "Bebe Rexha")
        let arianaGrande = User(id: 2, name: "Ariana Grande")
        switch storageCore.replace(bebeRexha) {
        case .success():
            break
        case .failure(let error):
            throw error
        }
        switch storageCore.replace(arianaGrande) {
        case .success():
            break
        case .failure(let error):
            throw error
        }
        var getAllResult: Result<[User], Error> = storageCore.getAll([])
        switch getAllResult {
        case .success(let allUsers):
            XCTAssert(compareUnordered(allUsers, [bebeRexha, arianaGrande]))
        case .failure(let error):
            throw error
        }

        switch storageCore.delete(bebeRexha) {
        case .success():
            break
        case .failure(let error):
            throw error
        }
        getAllResult = storageCore.getAll([])
        switch getAllResult {
        case .success(let allUsers):
            XCTAssert(allUsers == [arianaGrande])
        case .failure(let error):
            throw error
        }
    }
    
    func testReplace() throws {
        let storageCore = try StorageCoreImpl(filename: "",
                                              tables: Table<User>(name: "users",
                                                                  columns:
                                                                    Column(name: "id", keyPath: \User.id, constraints: primaryKey(), notNull()),
                                                                  Column(name: "name", keyPath: \User.name, constraints: notNull())))
        switch storageCore.syncSchema(preserve: true) {
        case .success(_):
            break
        case .failure(let error):
            throw error
        }

        var getAllResult: Result<[User], Error> = storageCore.getAll([])
        switch getAllResult {
        case .success(let allUsers):
            XCTAssertTrue(allUsers.isEmpty)
        case .failure(let error):
            throw error
        }

        let bebeRexha = User(id: 1, name: "Bebe Rexha")
        switch storageCore.replace(bebeRexha) {
        case .success():
            break
        case .failure(let error):
            throw error
        }

        getAllResult = storageCore.getAll([])
        switch getAllResult {
        case .success(let allUsers):
            XCTAssertEqual(allUsers, [bebeRexha])
        case .failure(let error):
            throw error
        }

        let arianaGrande = User(id: 2, name: "Ariana Grande")
        switch storageCore.replace(arianaGrande) {
        case .success():
            break
        case .failure(let error):
            throw error
        }

        getAllResult = storageCore.getAll([])
        switch getAllResult {
        case .success(let allUsers):
            XCTAssert(compareUnordered(allUsers, [bebeRexha, arianaGrande]))
        case .failure(let error):
            throw error
        }
    }
    
    func testUpdate() throws {
        let storageCore = try StorageCoreImpl(filename: "",
                                              tables: Table<User>(name: "users",
                                                                  columns:
                                                                    Column(name: "id", keyPath: \User.id, constraints: primaryKey(), notNull()),
                                                                  Column(name: "name", keyPath: \User.name, constraints: notNull())))
        switch storageCore.syncSchema(preserve: true) {
        case .success(_):
            break
        case .failure(let error):
            throw error
        }
        var bebeRexha = User(id: 1, name: "Bebe Rexha")
        switch storageCore.replace(bebeRexha) {
        case .success():
            break
        case .failure(let error):
            throw error
        }
        var getAllResult: Result<[User], Error> = storageCore.getAll([])
        switch getAllResult {
        case .success(let allUsers):
            XCTAssertEqual(allUsers, [bebeRexha])
        case .failure(let error):
            throw error
        }

        bebeRexha.name = "Ariana Grande"
        switch storageCore.update(bebeRexha) {
        case .success():
            break
        case .failure(let error):
            throw error
        }
        getAllResult = storageCore.getAll([])
        switch getAllResult {
        case .success(let allUsers):
            XCTAssertEqual(allUsers, [bebeRexha])
        case .failure(let error):
            throw error
        }
    }
    
    func testGet() throws {
        let storageCore = try StorageCoreImpl(filename: "",
                                              tables: Table<User>(name: "users",
                                                                  columns:
                                                                    Column(name: "id", keyPath: \User.id, constraints: primaryKey(), notNull()),
                                                                  Column(name: "name", keyPath: \User.name, constraints: notNull())))
        var getResult: Result<User?, Error> = storageCore.get(id: [1])
        switch getResult {
        case .success(_):
            XCTAssert(false)
        case .failure(let error):
            switch error {
            case SQLiteORM.Error.sqliteError(_, _):
                XCTAssert(true)
            default:
                XCTAssert(false)
            }
        }
        switch storageCore.syncSchema(preserve: true) {
        case .success(_):
            break
        case .failure(let error):
            throw error
        }

        switch storageCore.replace(User(id: 1, name: "Bebe Rexha")) {
        case .success():
            break
        case .failure(let error):
            throw error
        }
        getResult = storageCore.get(id: [1])
        switch getResult {
        case .success(let bebeRexhaMaybe):
            XCTAssertEqual(bebeRexhaMaybe, User(id: 1, name: "Bebe Rexha"))
        case .failure(let error):
            throw error
        }
        
        for id in 2..<10 {
            getResult = storageCore.get(id: [id])
            switch getResult {
            case .success(let user):
                XCTAssert(user == nil)
            case .failure(let error):
                throw error
            }
        }
    }
}
