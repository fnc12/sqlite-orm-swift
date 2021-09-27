import Foundation
import XCTest

struct SectionIteration {
    static var all = [SectionIteration]()
    
    var sectionsCount = 0
    var currentSectionIndex = 0
    var sectionsPassed = 0
    var passedSectionNames = [String]()
}

func testCase(_ name: String, routine: @escaping (() throws -> ())) throws {
    SectionIteration.all.append(SectionIteration())
    let iterationIndex = SectionIteration.all.count - 1
    repeat {
        try routine()
        SectionIteration.all[iterationIndex].currentSectionIndex += 1
        SectionIteration.all[iterationIndex].sectionsPassed = 0
        SectionIteration.all[iterationIndex].passedSectionNames.removeAll()
    } while SectionIteration.all[iterationIndex].currentSectionIndex < SectionIteration.all[iterationIndex].sectionsCount
    SectionIteration.all.removeLast()
}

func section(_ name: String, routine: @escaping (() throws -> ())) throws {
    let outerIterationIndex = SectionIteration.all.count - 1
    if SectionIteration.all[outerIterationIndex].passedSectionNames.contains(name) {
        fatalError("Section \(name) already exists in this context")
    }
    if 0 == SectionIteration.all[outerIterationIndex].currentSectionIndex {
        SectionIteration.all[outerIterationIndex].sectionsCount += 1
    }
    if SectionIteration.all[outerIterationIndex].currentSectionIndex == SectionIteration.all[outerIterationIndex].sectionsPassed {
        SectionIteration.all.append(SectionIteration())
        let iterationIndex = SectionIteration.all.count - 1
        repeat {
            try routine()
            SectionIteration.all[iterationIndex].currentSectionIndex += 1
            SectionIteration.all[iterationIndex].sectionsPassed = 0
            SectionIteration.all[iterationIndex].passedSectionNames.removeAll()
        } while SectionIteration.all[iterationIndex].currentSectionIndex < SectionIteration.all[iterationIndex].sectionsCount
        SectionIteration.all.removeLast()
    }
    SectionIteration.all[outerIterationIndex].sectionsPassed += 1
    SectionIteration.all[outerIterationIndex].passedSectionNames.append(name)
}

class SectionsTest: XCTestCase {
    func test() throws {
        var totalText = ""
        try testCase(#function) {
            var text = ""
            var expected = ""
            totalText += "1"
            
            text += "a"
            try section("a") {
                text += "b"
                totalText += "2"
                try section("c") {
                    totalText += "4"
                }
                try section("d") {
                    totalText += "5"
                }
                expected = "abb"
            }
            try section("b") {
                text += "c"
                expected = "ac"
                totalText += "3"
            }
            XCTAssertEqual(text, expected)
        }
        XCTAssertEqual(totalText, "1242513")
    }
}
