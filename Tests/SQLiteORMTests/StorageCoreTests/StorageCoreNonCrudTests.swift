import XCTest
@testable import SQLiteORM

class StorageCoreNonCrudTests: XCTestCase {
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

    func testSelect() throws {
        struct Employee {
            var id = 0
            var firstname = ""
            var lastname = ""
            var title = ""
            var email = ""
        }
        try testCase(#function, routine: {
            let apiProvider = SQLiteApiProviderMock()
            apiProvider.forwardsCalls = true
            let filename = "update_all.sqlite"
            remove(filename)
            let storageCore = try StorageCoreImpl(filename: filename,
                                                  apiProvider: apiProvider,
                                                  tables: [
                                                    Table<Employee>(name: "employees",
                                                                    elements: [
                                                                        Column(name: "id", keyPath: \Employee.id, constraints: primaryKey()),
                                                                        Column(name: "firstname", keyPath: \Employee.firstname),
                                                                        Column(name: "lastname", keyPath: \Employee.lastname),
                                                                        Column(name: "title", keyPath: \Employee.title),
                                                                        Column(name: "email", keyPath: \Employee.email)
                                                                    ])
                                                  ])
            switch storageCore.syncSchema(preserve: false) {
            case .success(_):
                break
            case .failure(let error):
                throw error
            }
            switch storageCore.replace(Employee(id: 1,
                                                firstname: "Andrew",
                                                lastname: "Adams",
                                                title: "General Manager",
                                                email: "andrew@chinookcorp.com")) {
            case .success():
                break
            case .failure(let error):
                throw error
            }
            switch storageCore.replace(Employee(id: 2,
                                                firstname: "Nancy",
                                                lastname: "Edwards",
                                                title: "Sales Manager",
                                                email: "nancy@chinookcorp.com")) {
            case .success():
                break
            case .failure(let error):
                throw error
            }
            switch storageCore.replace(Employee(id: 3,
                                                firstname: "Jane",
                                                lastname: "Peacock",
                                                title: "Sales Support Agent",
                                                email: "jane@chinookcorp.com")) {
            case .success():
                break
            case .failure(let error):
                throw error
            }
            switch storageCore.replace(Employee(id: 4,
                                                firstname: "Margaret",
                                                lastname: "Park",
                                                title: "Sales Support Agent",
                                                email: "margaret@chinookcorp.com")) {
            case .success():
                break
            case .failure(let error):
                throw error
            }
            switch storageCore.replace(Employee(id: 5,
                                                firstname: "Steve",
                                                lastname: "Johnson",
                                                title: "Sales Support Agent",
                                                email: "steve@chinookcorp.com")) {
            case .success():
                break
            case .failure(let error):
                throw error
            }
            switch storageCore.replace(Employee(id: 6,
                                                firstname: "Michael",
                                                lastname: "Mitchell",
                                                title: "IT Manager",
                                                email: "michael@chinookcorp.com")) {
            case .success():
                break
            case .failure(let error):
                throw error
            }
            switch storageCore.replace(Employee(id: 7,
                                                firstname: "Robert",
                                                lastname: "King",
                                                title: "IT Staff",
                                                email: "robert@chinookcorp.com")) {
            case .success():
                break
            case .failure(let error):
                throw error
            }
            switch storageCore.replace(Employee(id: 8,
                                                firstname: "Laura",
                                                lastname: "Callahan",
                                                title: "IT Staff",
                                                email: "laura@chinookcorp.com")) {
            case .success():
                break
            case .failure(let error):
                throw error
            }
            
            apiProvider.resetCalls()
            try section("one column", routine: {
                let selectResult: Result<[Int], Error> = storageCore.select(\Employee.id, [from(Employee.self)])
                switch selectResult {
                case .success(let ids):
                    let expected: [Int] = Array(1...8)
                    XCTAssert(compareUnordered(ids, expected))
                    XCTAssertEqual(apiProvider.calls, [
                        .init(id: 0, callType: .sqlite3Open(filename, .ignore)),
                        .init(id: 1, callType: .sqlite3PrepareV2(.ignore, "SELECT employees.\"id\" FROM employees", -1, .ignore, nil)),
                        .init(id: 2, callType: .sqlite3Step(.ignore)),
                        .init(id: 3, callType: .sqlite3ColumnCount(.ignore)),
                        .init(id: 4, callType: .sqlite3ColumnInt(.ignore, 0)),
                        .init(id: 5, callType: .sqlite3Step(.ignore)),
                        .init(id: 6, callType: .sqlite3ColumnCount(.ignore)),
                        .init(id: 7, callType: .sqlite3ColumnInt(.ignore, 0)),
                        .init(id: 8, callType: .sqlite3Step(.ignore)),
                        .init(id: 9, callType: .sqlite3ColumnCount(.ignore)),
                        .init(id: 10, callType: .sqlite3ColumnInt(.ignore, 0)),
                        .init(id: 11, callType: .sqlite3Step(.ignore)),
                        .init(id: 12, callType: .sqlite3ColumnCount(.ignore)),
                        .init(id: 13, callType: .sqlite3ColumnInt(.ignore, 0)),
                        .init(id: 14, callType: .sqlite3Step(.ignore)),
                        .init(id: 15, callType: .sqlite3ColumnCount(.ignore)),
                        .init(id: 16, callType: .sqlite3ColumnInt(.ignore, 0)),
                        .init(id: 17, callType: .sqlite3Step(.ignore)),
                        .init(id: 18, callType: .sqlite3ColumnCount(.ignore)),
                        .init(id: 19, callType: .sqlite3ColumnInt(.ignore, 0)),
                        .init(id: 20, callType: .sqlite3Step(.ignore)),
                        .init(id: 21, callType: .sqlite3ColumnCount(.ignore)),
                        .init(id: 22, callType: .sqlite3ColumnInt(.ignore, 0)),
                        .init(id: 23, callType: .sqlite3Step(.ignore)),
                        .init(id: 24, callType: .sqlite3ColumnCount(.ignore)),
                        .init(id: 25, callType: .sqlite3ColumnInt(.ignore, 0)),
                        .init(id: 26, callType: .sqlite3Step(.ignore)),
                        .init(id: 27, callType: .sqlite3ColumnCount(.ignore)),
                        .init(id: 28, callType: .sqlite3Finalize(.ignore)),
                        .init(id: 29, callType: .sqlite3Close(.ignore))
                    ])
                case .failure(let error):
                    throw error
                }
            })
            try section("two columns", routine: {
                let selectResult: Result<[(Int, String)], Error> = storageCore.select(\Employee.id, \Employee.firstname,
                                                                                       [from(Employee.self)])
                switch selectResult {
                case .success(let rows):
                    let expected: [(Int, String)] = [
                        (1, "Andrew"),
                        (2, "Nancy"),
                        (3, "Jane"),
                        (4, "Margaret"),
                        (5, "Steve"),
                        (6, "Michael"),
                        (7, "Robert"),
                        (8, "Laura")
                    ]
                    XCTAssert(compareUnordered(rows, expected, { $0.0 == $1.0 && $0.1 == $1.1 }))
                    XCTAssertEqual(apiProvider.calls, [
                        .init(id: 0, callType: .sqlite3Open(filename, .ignore)),
                        .init(id: 1, callType: .sqlite3PrepareV2(.ignore, "SELECT employees.\"id\", employees.\"firstname\" FROM employees", -1, .ignore, nil)),
                        .init(id: 2, callType: .sqlite3Step(.ignore)),
                        .init(id: 3, callType: .sqlite3ColumnCount(.ignore)),
                        .init(id: 4, callType: .sqlite3ColumnInt(.ignore, 0)),
                        .init(id: 5, callType: .sqlite3ColumnText(.ignore, 1)),
                        .init(id: 6, callType: .sqlite3Step(.ignore)),
                        .init(id: 7, callType: .sqlite3ColumnCount(.ignore)),
                        .init(id: 8, callType: .sqlite3ColumnInt(.ignore, 0)),
                        .init(id: 9, callType: .sqlite3ColumnText(.ignore, 1)),
                        .init(id: 10, callType: .sqlite3Step(.ignore)),
                        .init(id: 11, callType: .sqlite3ColumnCount(.ignore)),
                        .init(id: 12, callType: .sqlite3ColumnInt(.ignore, 0)),
                        .init(id: 13, callType: .sqlite3ColumnText(.ignore, 1)),
                        .init(id: 14, callType: .sqlite3Step(.ignore)),
                        .init(id: 15, callType: .sqlite3ColumnCount(.ignore)),
                        .init(id: 16, callType: .sqlite3ColumnInt(.ignore, 0)),
                        .init(id: 17, callType: .sqlite3ColumnText(.ignore, 1)),
                        .init(id: 18, callType: .sqlite3Step(.ignore)),
                        .init(id: 19, callType: .sqlite3ColumnCount(.ignore)),
                        .init(id: 20, callType: .sqlite3ColumnInt(.ignore, 0)),
                        .init(id: 21, callType: .sqlite3ColumnText(.ignore, 1)),
                        .init(id: 22, callType: .sqlite3Step(.ignore)),
                        .init(id: 23, callType: .sqlite3ColumnCount(.ignore)),
                        .init(id: 24, callType: .sqlite3ColumnInt(.ignore, 0)),
                        .init(id: 25, callType: .sqlite3ColumnText(.ignore, 1)),
                        .init(id: 26, callType: .sqlite3Step(.ignore)),
                        .init(id: 27, callType: .sqlite3ColumnCount(.ignore)),
                        .init(id: 28, callType: .sqlite3ColumnInt(.ignore, 0)),
                        .init(id: 29, callType: .sqlite3ColumnText(.ignore, 1)),
                        .init(id: 30, callType: .sqlite3Step(.ignore)),
                        .init(id: 31, callType: .sqlite3ColumnCount(.ignore)),
                        .init(id: 32, callType: .sqlite3ColumnInt(.ignore, 0)),
                        .init(id: 33, callType: .sqlite3ColumnText(.ignore, 1)),
                        .init(id: 34, callType: .sqlite3Step(.ignore)),
                        .init(id: 35, callType: .sqlite3ColumnCount(.ignore)),
                        .init(id: 36, callType: .sqlite3Finalize(.ignore)),
                        .init(id: 37, callType: .sqlite3Close(.ignore))
                    ])
                case .failure(let error):
                    throw error
                }
            })
            try section("three columns", routine: {
                let selectResult: Result<[(Int, String, String)], Error> = storageCore.select(\Employee.id,
                                                                                               \Employee.firstname,
                                                                                               \Employee.lastname,
                                                                                               [from(Employee.self)])
                switch selectResult {
                case .success(let rows):
                    let expected: [(Int, String, String)] = [
                        (1, "Andrew", "Adams"),
                        (2, "Nancy", "Edwards"),
                        (3, "Jane", "Peacock"),
                        (4, "Margaret", "Park"),
                        (5, "Steve", "Johnson"),
                        (6, "Michael", "Mitchell"),
                        (7, "Robert", "King"),
                        (8, "Laura", "Callahan"),
                    ]
                    XCTAssert(compareUnordered(rows, expected, { $0.0 == $1.0 && $0.1 == $1.1 && $0.2 == $1.2 }))
                    XCTAssertEqual(apiProvider.calls, [
                        .init(id: 0, callType: .sqlite3Open(filename, .ignore)),
                        .init(id: 1, callType: .sqlite3PrepareV2(.ignore, "SELECT employees.\"id\", employees.\"firstname\", employees.\"lastname\" FROM employees", -1, .ignore, nil)),
                        .init(id: 2, callType: .sqlite3Step(.ignore)),
                        .init(id: 3, callType: .sqlite3ColumnCount(.ignore)),
                        .init(id: 4, callType: .sqlite3ColumnInt(.ignore, 0)),
                        .init(id: 5, callType: .sqlite3ColumnText(.ignore, 1)),
                        .init(id: 6, callType: .sqlite3ColumnText(.ignore, 2)),
                        .init(id: 7, callType: .sqlite3Step(.ignore)),
                        .init(id: 8, callType: .sqlite3ColumnCount(.ignore)),
                        .init(id: 9, callType: .sqlite3ColumnInt(.ignore, 0)),
                        .init(id: 10, callType: .sqlite3ColumnText(.ignore, 1)),
                        .init(id: 11, callType: .sqlite3ColumnText(.ignore, 2)),
                        .init(id: 12, callType: .sqlite3Step(.ignore)),
                        .init(id: 13, callType: .sqlite3ColumnCount(.ignore)),
                        .init(id: 14, callType: .sqlite3ColumnInt(.ignore, 0)),
                        .init(id: 15, callType: .sqlite3ColumnText(.ignore, 1)),
                        .init(id: 16, callType: .sqlite3ColumnText(.ignore, 2)),
                        .init(id: 17, callType: .sqlite3Step(.ignore)),
                        .init(id: 18, callType: .sqlite3ColumnCount(.ignore)),
                        .init(id: 19, callType: .sqlite3ColumnInt(.ignore, 0)),
                        .init(id: 20, callType: .sqlite3ColumnText(.ignore, 1)),
                        .init(id: 21, callType: .sqlite3ColumnText(.ignore, 2)),
                        .init(id: 22, callType: .sqlite3Step(.ignore)),
                        .init(id: 23, callType: .sqlite3ColumnCount(.ignore)),
                        .init(id: 24, callType: .sqlite3ColumnInt(.ignore, 0)),
                        .init(id: 25, callType: .sqlite3ColumnText(.ignore, 1)),
                        .init(id: 26, callType: .sqlite3ColumnText(.ignore, 2)),
                        .init(id: 27, callType: .sqlite3Step(.ignore)),
                        .init(id: 28, callType: .sqlite3ColumnCount(.ignore)),
                        .init(id: 29, callType: .sqlite3ColumnInt(.ignore, 0)),
                        .init(id: 30, callType: .sqlite3ColumnText(.ignore, 1)),
                        .init(id: 31, callType: .sqlite3ColumnText(.ignore, 2)),
                        .init(id: 32, callType: .sqlite3Step(.ignore)),
                        .init(id: 33, callType: .sqlite3ColumnCount(.ignore)),
                        .init(id: 34, callType: .sqlite3ColumnInt(.ignore, 0)),
                        .init(id: 35, callType: .sqlite3ColumnText(.ignore, 1)),
                        .init(id: 36, callType: .sqlite3ColumnText(.ignore, 2)),
                        .init(id: 37, callType: .sqlite3Step(.ignore)),
                        .init(id: 38, callType: .sqlite3ColumnCount(.ignore)),
                        .init(id: 39, callType: .sqlite3ColumnInt(.ignore, 0)),
                        .init(id: 40, callType: .sqlite3ColumnText(.ignore, 1)),
                        .init(id: 41, callType: .sqlite3ColumnText(.ignore, 2)),
                        .init(id: 42, callType: .sqlite3Step(.ignore)),
                        .init(id: 43, callType: .sqlite3ColumnCount(.ignore)),
                        .init(id: 44, callType: .sqlite3Finalize(.ignore)),
                        .init(id: 45, callType: .sqlite3Close(.ignore)),
                    ])
                case .failure(let error):
                    throw error
                }
            })
        })
    }

    func testUpdateAll() throws {
        struct Employee {
            var id = 0
            var firstname = ""
            var lastname = ""
            var title = ""
            var email = ""
        }
        try testCase(#function, routine: {
            let apiProvider = SQLiteApiProviderMock()
            apiProvider.forwardsCalls = true
            let filename = "update_all.sqlite"
            remove(filename)
            let storageCore = try StorageCoreImpl(filename: filename,
                                                  apiProvider: apiProvider,
                                                  tables: [Table<Employee>(name: "employees",
                                                                           elements: [
                                                                            Column(name: "id", keyPath: \Employee.id, constraints:  primaryKey()),
                                                                            Column(name: "firstname", keyPath: \Employee.firstname),
                                                                            Column(name: "lastname", keyPath: \Employee.lastname),
                                                                            Column(name: "title", keyPath: \Employee.title),
                                                                            Column(name: "email", keyPath: \Employee.email)])])
            switch storageCore.syncSchema(preserve: false) {
            case .success(_):
                break
            case .failure(let error):
                throw error
            }
            switch storageCore.replace(Employee(id: 1,
                                                firstname: "Andrew",
                                                lastname: "Adams",
                                                title: "General Manager",
                                                email: "andrew@chinookcorp.com")) {
            case .success():
                break
            case .failure(let error):
                throw error
            }
            switch storageCore.replace(Employee(id: 2,
                                                firstname: "Nancy",
                                                lastname: "Edwards",
                                                title: "Sales Manager",
                                                email: "nancy@chinookcorp.com")) {
            case .success():
                break
            case .failure(let error):
                throw error
            }
            switch storageCore.replace(Employee(id: 3,
                                                firstname: "Jane",
                                                lastname: "Peacock",
                                                title: "Sales Support Agent",
                                                email: "jane@chinookcorp.com")) {
            case .success():
                break
            case .failure(let error):
                throw error
            }
            switch storageCore.replace(Employee(id: 4,
                                                firstname: "Margaret",
                                                lastname: "Park",
                                                title: "Sales Support Agent",
                                                email: "margaret@chinookcorp.com")) {
            case .success():
                break
            case .failure(let error):
                throw error
            }
            switch storageCore.replace(Employee(id: 5,
                                                firstname: "Steve",
                                                lastname: "Johnson",
                                                title: "Sales Support Agent",
                                                email: "steve@chinookcorp.com")) {
            case .success():
                break
            case .failure(let error):
                throw error
            }
            switch storageCore.replace(Employee(id: 6,
                                                firstname: "Michael",
                                                lastname: "Mitchell",
                                                title: "IT Manager",
                                                email: "michael@chinookcorp.com")) {
            case .success():
                break
            case .failure(let error):
                throw error
            }
            switch storageCore.replace(Employee(id: 7,
                                                firstname: "Robert",
                                                lastname: "King",
                                                title: "IT Staff",
                                                email: "robert@chinookcorp.com")) {
            case .success():
                break
            case .failure(let error):
                throw error
            }
            switch storageCore.replace(Employee(id: 8,
                                                firstname: "Laura",
                                                lastname: "Callahan",
                                                title: "IT Staff",
                                                email: "laura@chinookcorp.com")) {
            case .success():
                break
            case .failure(let error):
                throw error
            }

            apiProvider.resetCalls()
            try section("function", routine: {
                switch storageCore.update(all: Employee.self,
                                          set(assign(\Employee.lastname, "Smith")),
                                          [where_(equal(lhs: \Employee.id, rhs: 3))]) {
                case .success():
                    break
                case .failure(let error):
                    throw error
                }
            })
            try section("operator", routine: {
                switch storageCore.update(all: Employee.self,
                                          set(\Employee.lastname &= "Smith"),
                                          [where_(\Employee.id == 3)]) {
                case .success():
                    break
                case .failure(let error):
                    throw error
                }
            })
            XCTAssertEqual(apiProvider.calls, [
                .init(id: 0, callType: .sqlite3Open(filename, .ignore)),
                .init(id: 1, callType: .sqlite3PrepareV2(.ignore, "UPDATE employees SET \"lastname\" = 'Smith' WHERE (employees.\"id\" == 3)", -1, .ignore, nil)),
                .init(id: 2, callType: .sqlite3Step(.ignore)),
                .init(id: 3, callType: .sqlite3Finalize(.ignore)),
                .init(id: 4, callType: .sqlite3Close(.ignore))
            ])
        })
    }

    func testGetAll() throws {
        try testCase(#function, routine: {
            let apiProvider = SQLiteApiProviderMock()
            apiProvider.forwardsCalls = true
            let createStorageCore = { (filename: String) throws -> StorageCoreImpl in
                let storageCore = try StorageCoreImpl(filename: filename,
                                                      apiProvider: apiProvider,
                                                      tables: [Table<User>(name: "users",
                                                                           elements: [
                                                                            Column(name: "id", keyPath: \User.id, constraints: primaryKey(), notNull()),
                                                                            Column(name: "name", keyPath: \User.name, constraints: notNull())])])
                switch storageCore.syncSchema(preserve: false) {
                case .success(_):
                    break
                case .failure(let error):
                    throw error
                }
                return storageCore
            }
            try section("error", routine: {
                let storageCore = try createStorageCore("")
                let getAllResult: Result<[Visit], Error> = storageCore.getAll([])
                switch getAllResult {
                case .success(_):
                    XCTAssert(false)
                case .failure(let error):
                    switch error {
                    case SQLiteORM.Error.typeIsNotMapped:
                        XCTAssert(true)
                    default:
                        XCTAssert(false)
                    }
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
                let storageCore = try createStorageCore(filename)
                var expectedCalls = [SQLiteApiProviderMock.Call]()
                if inMemory {
                    let db = storageCore.connection.dbMaybe!
                    expectedCalls = [
                        .init(id: 0, callType: .sqlite3PrepareV2(.value(db), "SELECT * FROM users", -1, .ignore, nil)),
                        .init(id: 1, callType: .sqlite3Step(.ignore)),
                        .init(id: 2, callType: .sqlite3ColumnCount(.ignore)),
                        .init(id: 3, callType: .sqlite3Finalize(.ignore))
                    ]
                } else {
                    expectedCalls = [
                        .init(id: 0, callType: .sqlite3Open(filename, .ignore)),
                        .init(id: 1, callType: .sqlite3PrepareV2(.ignore, "SELECT * FROM users", -1, .ignore, nil)),
                        .init(id: 2, callType: .sqlite3Step(.ignore)),
                        .init(id: 3, callType: .sqlite3ColumnCount(.ignore)),
                        .init(id: 4, callType: .sqlite3Finalize(.ignore)),
                        .init(id: 5, callType: .sqlite3Close(.ignore))
                    ]
                }
                apiProvider.resetCalls()
                var getAllResult: Result<[User], Error> = storageCore.getAll(all: User.self, [])
                switch getAllResult {
                case .success(let users):
                    XCTAssertEqual(apiProvider.calls, expectedCalls)
                    XCTAssertEqual(users, [])
                case .failure(let error):
                    throw error
                }

                switch storageCore.replace(User(id: 3, name: "Ted")) {
                case .success():
                    break
                case .failure(let error):
                    throw error
                }
                if inMemory {
                    let db = storageCore.connection.dbMaybe!
                    expectedCalls = [
                        .init(id: 0, callType: .sqlite3PrepareV2(.value(db), "SELECT * FROM users", -1, .ignore, nil)),
                        .init(id: 1, callType: .sqlite3Step(.ignore)),
                        .init(id: 2, callType: .sqlite3ColumnCount(.ignore)),
                        .init(id: 3, callType: .sqlite3ColumnInt(.ignore, 0)),
                        .init(id: 4, callType: .sqlite3ColumnText(.ignore, 1)),
                        .init(id: 5, callType: .sqlite3Step(.ignore)),
                        .init(id: 6, callType: .sqlite3ColumnCount(.ignore)),
                        .init(id: 7, callType: .sqlite3Finalize(.ignore))
                    ]
                } else {
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
                        .init(id: 9, callType: .sqlite3Close(.ignore))
                    ]
                }
                apiProvider.resetCalls()
                getAllResult = storageCore.getAll([])
                switch getAllResult {
                case .success(let users):
                    XCTAssertEqual(apiProvider.calls, expectedCalls)
                    XCTAssertEqual(users, [User(id: 3, name: "Ted")])
                case .failure(let error):
                    throw error
                }

                apiProvider.resetCalls()
                if inMemory {
                    expectedCalls = [
                        .init(id: 0, callType: .sqlite3PrepareV2(.ignore, "SELECT * FROM users WHERE (users.\"id\" == 5)", -1, .ignore, nil)),
                        .init(id: 1, callType: .sqlite3Step(.ignore)),
                        .init(id: 2, callType: .sqlite3ColumnCount(.ignore)),
                        .init(id: 3, callType: .sqlite3Finalize(.ignore))
                    ]
                } else {
                    expectedCalls = [
                        .init(id: 0, callType: .sqlite3Open(filename, .ignore)),
                        .init(id: 1, callType: .sqlite3PrepareV2(.ignore, "SELECT * FROM users WHERE (users.\"id\" == 5)", -1, .ignore, nil)),
                        .init(id: 2, callType: .sqlite3Step(.ignore)),
                        .init(id: 3, callType: .sqlite3ColumnCount(.ignore)),
                        .init(id: 4, callType: .sqlite3Finalize(.ignore)),
                        .init(id: 5, callType: .sqlite3Close(.ignore))
                    ]
                }
                getAllResult = storageCore.getAll([where_(equal(lhs: \User.id, rhs: 5))])
                switch getAllResult {
                case .success(let users):
                    XCTAssertEqual(apiProvider.calls, expectedCalls)
                    XCTAssertEqual(users, [])
                case .failure(let error):
                    throw error
                }

                apiProvider.resetCalls()
                if inMemory {
                    let db = storageCore.connection.dbMaybe!
                    expectedCalls = [
                        .init(id: 0, callType: .sqlite3PrepareV2(.value(db), "SELECT * FROM users WHERE (users.\"id\" == 3)", -1, .ignore, nil)),
                        .init(id: 1, callType: .sqlite3Step(.ignore)),
                        .init(id: 2, callType: .sqlite3ColumnCount(.ignore)),
                        .init(id: 3, callType: .sqlite3ColumnInt(.ignore, 0)),
                        .init(id: 4, callType: .sqlite3ColumnText(.ignore, 1)),
                        .init(id: 5, callType: .sqlite3Step(.ignore)),
                        .init(id: 6, callType: .sqlite3ColumnCount(.ignore)),
                        .init(id: 7, callType: .sqlite3Finalize(.ignore))
                    ]
                } else {
                    expectedCalls = [
                        .init(id: 0, callType: .sqlite3Open(filename, .ignore)),
                        .init(id: 1, callType: .sqlite3PrepareV2(.ignore, "SELECT * FROM users WHERE (users.\"id\" == 3)", -1, .ignore, nil)),
                        .init(id: 2, callType: .sqlite3Step(.ignore)),
                        .init(id: 3, callType: .sqlite3ColumnCount(.ignore)),
                        .init(id: 4, callType: .sqlite3ColumnInt(.ignore, 0)),
                        .init(id: 5, callType: .sqlite3ColumnText(.ignore, 1)),
                        .init(id: 6, callType: .sqlite3Step(.ignore)),
                        .init(id: 7, callType: .sqlite3ColumnCount(.ignore)),
                        .init(id: 8, callType: .sqlite3Finalize(.ignore)),
                        .init(id: 9, callType: .sqlite3Close(.ignore))
                    ]
                }
                apiProvider.resetCalls()
                getAllResult = storageCore.getAll([where_(equal(lhs: \User.id, rhs: 3))])
                switch getAllResult {
                case .success(let users):
                    XCTAssertEqual(apiProvider.calls, expectedCalls)
                    XCTAssertEqual(users, [User(id: 3, name: "Ted")])
                case .failure(let error):
                    throw error
                }
            })
        })
    }

    func testDeleteAll() throws {
        try testCase(#function, routine: {
            let apiProvider = SQLiteApiProviderMock()
            apiProvider.forwardsCalls = true
            let createStorageCore = { (filename: String) throws -> StorageCoreImpl in
                let storageCore = try StorageCoreImpl(filename: filename,
                                                      apiProvider: apiProvider,
                                                      tables: [Table<User>(name: "users",
                                                                           elements: [
                                                                            Column(name: "id", keyPath: \User.id, constraints: primaryKey(), notNull()),
                                                                            Column(name: "name", keyPath: \User.name, constraints: notNull())])])
                switch storageCore.syncSchema(preserve: false) {
                case .success(_):
                    break
                case .failure(let error):
                    throw error
                }
                return storageCore
            }
            try section("error", routine: {
                let storageCore = try createStorageCore("")
                switch storageCore.delete(all: Visit.self, []) {
                case .success():
                    XCTAssert(false)
                case .failure(let error):
                    switch error {
                    case SQLiteORM.Error.typeIsNotMapped:
                        XCTAssert(true)
                    default:
                        XCTAssert(false)
                    }
                }
            })
            try section("no error", routine: {
                var expectedCalls = [SQLiteApiProviderMock.Call]()
                var sqliteCalls = [SQLiteApiProviderMock.Call]()
                try section("no conditions", routine: {
                    var filename = ""
                    try section("file", routine: {
                        filename = "db.sqlite"
                        remove(filename)
                        expectedCalls = [
                            .init(id: 0, callType: .sqlite3Open(filename, .ignore)),
                            .init(id: 1, callType: .sqlite3PrepareV2(.ignore, "DELETE FROM users", -1, .ignore, nil)),
                            .init(id: 2, callType: .sqlite3Step(.ignore)),
                            .init(id: 3, callType: .sqlite3Finalize(.ignore)),
                            .init(id: 4, callType: .sqlite3Close(.ignore))
                        ]
                    })
                    try section("memory", routine: {
                        expectedCalls = [
                            .init(id: 0, callType: .sqlite3PrepareV2(.ignore, "DELETE FROM users", -1, .ignore, nil)),
                            .init(id: 1, callType: .sqlite3Step(.ignore)),
                            .init(id: 2, callType: .sqlite3Finalize(.ignore))
                        ]
                    })
                    let storageCore = try createStorageCore(filename)
                    switch storageCore.syncSchema(preserve: false) {
                    case .success(_):
                        break
                    case .failure(let error):
                        throw error
                    }
                    apiProvider.resetCalls()
                    switch storageCore.delete(all: User.self, []) {
                    case .success():
                        break
                    case .failure(let error):
                        throw error
                    }
                    sqliteCalls = apiProvider.calls
                })
                try section("with conditions", routine: {
                    var filename = ""
                    try section("file", routine: {
                        filename = "db.sqlite"
                        remove(filename)
                        expectedCalls = [
                            .init(id: 0, callType: .sqlite3Open(filename, .ignore)),
                            .init(id: 1, callType: .sqlite3PrepareV2(.ignore, "DELETE FROM users WHERE (users.\"id\" < 10)", -1, .ignore, nil)),
                            .init(id: 2, callType: .sqlite3Step(.ignore)),
                            .init(id: 3, callType: .sqlite3Finalize(.ignore)),
                            .init(id: 4, callType: .sqlite3Close(.ignore))
                        ]
                    })
                    try section("memory", routine: {
                        expectedCalls = [
                            .init(id: 0, callType: .sqlite3PrepareV2(.ignore, "DELETE FROM users WHERE (users.\"id\" < 10)", -1, .ignore, nil)),
                            .init(id: 1, callType: .sqlite3Step(.ignore)),
                            .init(id: 2, callType: .sqlite3Finalize(.ignore))
                        ]
                    })
                    let storageCore = try createStorageCore(filename)
                    switch storageCore.syncSchema(preserve: false) {
                    case .success(_):
                        break
                    case .failure(let error):
                        throw error
                    }
                    apiProvider.resetCalls()
                    switch storageCore.delete(all: User.self, [where_(lesserThan(lhs: \User.id, rhs: 10))]) {
                    case .success():
                        break
                    case .failure(let error):
                        throw error
                    }
                    sqliteCalls = apiProvider.calls
                })
                XCTAssertEqual(sqliteCalls, expectedCalls)
            })
        })
    }
}
