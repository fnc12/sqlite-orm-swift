import XCTest
import SQLiteORM

class ColumnConstraintsTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testPrimaryKey() {
        struct TestCase {
            let constraintBuilder: ConstraintBuilder
            let constraint: ColumnConstraint
        }
        let testCases = [
            TestCase(constraintBuilder: primaryKey(),
                     constraint: .primaryKey(order: nil, conflictClause: nil, autoincrement: false)),
            
            TestCase(constraintBuilder: primaryKey().asc(),
                     constraint: .primaryKey(order: .asc, conflictClause: nil, autoincrement: false)),
            TestCase(constraintBuilder: primaryKey().desc(),
                     constraint: .primaryKey(order: .desc, conflictClause: nil, autoincrement: false)),
            
            TestCase(constraintBuilder: primaryKey().onConflict().rollback(),
                     constraint: .primaryKey(order: nil, conflictClause: .rollback, autoincrement: false)),
            TestCase(constraintBuilder: primaryKey().onConflict().abort(),
                     constraint: .primaryKey(order: nil, conflictClause: .abort, autoincrement: false)),
            TestCase(constraintBuilder: primaryKey().onConflict().fail(),
                     constraint: .primaryKey(order: nil, conflictClause: .fail, autoincrement: false)),
            TestCase(constraintBuilder: primaryKey().onConflict().ignore(),
                     constraint: .primaryKey(order: nil, conflictClause: .ignore, autoincrement: false)),
            TestCase(constraintBuilder: primaryKey().onConflict().replace(),
                     constraint: .primaryKey(order: nil, conflictClause: .replace, autoincrement: false)),
            
            TestCase(constraintBuilder: primaryKey().asc().onConflict().rollback(),
                     constraint: .primaryKey(order: .asc, conflictClause: .rollback, autoincrement: false)),
            TestCase(constraintBuilder: primaryKey().asc().onConflict().abort(),
                     constraint: .primaryKey(order: .asc, conflictClause: .abort, autoincrement: false)),
            TestCase(constraintBuilder: primaryKey().asc().onConflict().fail(),
                     constraint: .primaryKey(order: .asc, conflictClause: .fail, autoincrement: false)),
            TestCase(constraintBuilder: primaryKey().asc().onConflict().ignore(),
                     constraint: .primaryKey(order: .asc, conflictClause: .ignore, autoincrement: false)),
            TestCase(constraintBuilder: primaryKey().asc().onConflict().replace(),
                     constraint: .primaryKey(order: .asc, conflictClause: .replace, autoincrement: false)),
            
            TestCase(constraintBuilder: primaryKey().desc().onConflict().rollback(),
                     constraint: .primaryKey(order: .desc, conflictClause: .rollback, autoincrement: false)),
            TestCase(constraintBuilder: primaryKey().desc().onConflict().abort(),
                     constraint: .primaryKey(order: .desc, conflictClause: .abort, autoincrement: false)),
            TestCase(constraintBuilder: primaryKey().desc().onConflict().fail(),
                     constraint: .primaryKey(order: .desc, conflictClause: .fail, autoincrement: false)),
            TestCase(constraintBuilder: primaryKey().desc().onConflict().ignore(),
                     constraint: .primaryKey(order: .desc, conflictClause: .ignore, autoincrement: false)),
            TestCase(constraintBuilder: primaryKey().desc().onConflict().replace(),
                     constraint: .primaryKey(order: .desc, conflictClause: .replace, autoincrement: false)),
            
            TestCase(constraintBuilder: primaryKey().autoincrement(),
                     constraint: .primaryKey(order: nil, conflictClause: nil, autoincrement: true)),
            
            TestCase(constraintBuilder: primaryKey().asc().autoincrement(),
                     constraint: .primaryKey(order: .asc, conflictClause: nil, autoincrement: true)),
            TestCase(constraintBuilder: primaryKey().desc().autoincrement(),
                     constraint: .primaryKey(order: .desc, conflictClause: nil, autoincrement: true)),
            
            TestCase(constraintBuilder: primaryKey().onConflict().rollback().autoincrement(),
                     constraint: .primaryKey(order: nil, conflictClause: .rollback, autoincrement: true)),
            TestCase(constraintBuilder: primaryKey().onConflict().abort().autoincrement(),
                     constraint: .primaryKey(order: nil, conflictClause: .abort, autoincrement: true)),
            TestCase(constraintBuilder: primaryKey().onConflict().fail().autoincrement(),
                     constraint: .primaryKey(order: nil, conflictClause: .fail, autoincrement: true)),
            TestCase(constraintBuilder: primaryKey().onConflict().ignore().autoincrement(),
                     constraint: .primaryKey(order: nil, conflictClause: .ignore, autoincrement: true)),
            TestCase(constraintBuilder: primaryKey().onConflict().replace().autoincrement(),
                     constraint: .primaryKey(order: nil, conflictClause: .replace, autoincrement: true)),
            
            TestCase(constraintBuilder: primaryKey().asc().onConflict().rollback().autoincrement(),
                     constraint: .primaryKey(order: .asc, conflictClause: .rollback, autoincrement: true)),
            TestCase(constraintBuilder: primaryKey().asc().onConflict().abort().autoincrement(),
                     constraint: .primaryKey(order: .asc, conflictClause: .abort, autoincrement: true)),
            TestCase(constraintBuilder: primaryKey().asc().onConflict().fail().autoincrement(),
                     constraint: .primaryKey(order: .asc, conflictClause: .fail, autoincrement: true)),
            TestCase(constraintBuilder: primaryKey().asc().onConflict().ignore().autoincrement(),
                     constraint: .primaryKey(order: .asc, conflictClause: .ignore, autoincrement: true)),
            TestCase(constraintBuilder: primaryKey().asc().onConflict().replace().autoincrement(),
                     constraint: .primaryKey(order: .asc, conflictClause: .replace, autoincrement: true)),
            
            TestCase(constraintBuilder: primaryKey().desc().onConflict().rollback().autoincrement(),
                     constraint: .primaryKey(order: .desc, conflictClause: .rollback, autoincrement: true)),
            TestCase(constraintBuilder: primaryKey().desc().onConflict().abort().autoincrement(),
                     constraint: .primaryKey(order: .desc, conflictClause: .abort, autoincrement: true)),
            TestCase(constraintBuilder: primaryKey().desc().onConflict().fail().autoincrement(),
                     constraint: .primaryKey(order: .desc, conflictClause: .fail, autoincrement: true)),
            TestCase(constraintBuilder: primaryKey().desc().onConflict().ignore().autoincrement(),
                     constraint: .primaryKey(order: .desc, conflictClause: .ignore, autoincrement: true)),
            TestCase(constraintBuilder: primaryKey().desc().onConflict().replace().autoincrement(),
                     constraint: .primaryKey(order: .desc, conflictClause: .replace, autoincrement: true)),
        ]
        for testCase in testCases {
            let value = testCase.constraintBuilder.constraint
            XCTAssert(value == testCase.constraint)
        }
    }

}
