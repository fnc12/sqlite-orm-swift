import XCTest
@testable import SQLiteORM

class StorageCoreTests: XCTestCase {
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
            let storageCore = try StorageCoreImpl(filename: testCase.filename, apiProvider: apiProvider, tables: [])
            XCTAssertEqual(storageCore.filename, testCase.filename)
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
            var storageCore: StorageCore? = try StorageCoreImpl(filename: filename,
                                                                apiProvider: apiProvider,
                                                                tables: [])
            _ = storageCore
            ctorCalls = apiProvider.calls
            apiProvider.resetCalls()
            storageCore = nil
            dtorCalls = apiProvider.calls
            XCTAssertEqual(expectedCtorCalls, ctorCalls)
            XCTAssertEqual(expectedDtorCalls, dtorCalls)
        })
    }
    
    func testColumnNameWithReservedKeyword() throws {
        struct Object: Initializable {
            var id = 0
            var order = 0
        }
        let storageCore = try StorageCoreImpl(filename: "",
                                              tables:[ Table<Object>(name: "objects",
                                                                    columns:[
                                                                        Column(name: "id", keyPath: \Object.id),
                                                                        Column(name: "order", keyPath: \Object.order)
                                                                    ])])
        switch storageCore.syncSchema(preserve: true) {
        case .success(_):
            break
        case .failure(let error):
            throw error
        }
    }
}
