import Foundation
import XCTest

class SectionIteration {
    var name: String
    let parent: SectionIteration?
    var children = [SectionIteration]()
    var runCount = 0
    var isRunning = false
    var cachedLeavesCount = 0
    var didRunThisTime = false

    init(name: String, parent: SectionIteration?) {
        self.name = name
        self.parent = parent
    }

    func findTheFarestRunningChild() -> SectionIteration? {
        func findTheFarestRunningChild(_ target: SectionIteration) -> SectionIteration? {
            if target.children.isEmpty {
                return target
            } else {
                if let runningChild = target.children.first(where: { $0.isRunning }) {
                    return findTheFarestRunningChild(runningChild)
                } else {
                    return target
                }
            }
        }

        if self.isRunning {
            return findTheFarestRunningChild(self)
        } else {
            return nil
        }
    }

    static var root: SectionIteration?
}

enum TestError: Error {
    case testCaseInsideTestCaseIsProhibited
    case sectionIsNotLocatedInsideTestCase
    case noRunningSectionFound
}

func testCase(_ name: String, routine: @escaping (() throws -> Void)) throws {
    guard nil == SectionIteration.root else {
        throw TestError.testCaseInsideTestCaseIsProhibited
    }
    let root = SectionIteration(name: name, parent: nil)
    SectionIteration.root = root

    //  run for the first time
    root.isRunning = true
    try routine()
    root.isRunning = false
    root.runCount += 1

    func countLeaves(node: SectionIteration) -> Int {
        var res = 0
        if node.children.isEmpty {
            res = 1
        } else {
            for child in node.children {
                let childLeavesCount = countLeaves(node: child)
                child.cachedLeavesCount = childLeavesCount
                res += childLeavesCount
            }
        }
        return res
    }

    func resetDidRunFlag(node: SectionIteration) {
        node.didRunThisTime = false
        node.children.forEach(resetDidRunFlag)
    }

    //  run 2..<leavesCount times
    while root.runCount < countLeaves(node: root) {
        resetDidRunFlag(node: root)
        root.isRunning = true
        try routine()
        root.isRunning = false
        root.runCount += 1
    }

    SectionIteration.root = nil
}

func section(_ name: String, routine: @escaping (() throws -> Void)) throws {
    guard nil != SectionIteration.root else {
        throw TestError.sectionIsNotLocatedInsideTestCase
    }
    guard let theFarestRunningChild = SectionIteration.root!.findTheFarestRunningChild() else {
        throw TestError.noRunningSectionFound
    }
    if 0 == SectionIteration.root!.runCount {
        theFarestRunningChild.children.append(.init(name: name, parent: theFarestRunningChild))
        if theFarestRunningChild.children.count == 1 {
            theFarestRunningChild.children.last!.isRunning = true
            try routine()
            theFarestRunningChild.children.last!.isRunning = false
            theFarestRunningChild.children.last!.runCount += 1
        }
    } else {
        let thisSectionIteration: SectionIteration
        if let foundSectionIteration = theFarestRunningChild.children.first(where: { $0.name == name }) {
            thisSectionIteration = foundSectionIteration
            if thisSectionIteration.runCount < thisSectionIteration.cachedLeavesCount {
                let hasDidRunThisTimeChildren = thisSectionIteration.parent!.children.contains(where: { $0.didRunThisTime })
                if !hasDidRunThisTimeChildren {
                    thisSectionIteration.isRunning = true
                    try routine()
                    thisSectionIteration.isRunning = false
                    thisSectionIteration.didRunThisTime = true
                    thisSectionIteration.runCount += 1
                }
            }
        } else {
            thisSectionIteration = .init(name: name, parent: theFarestRunningChild)
            theFarestRunningChild.children.append(thisSectionIteration)
            let hasDidRunThisTimeChildren = thisSectionIteration.parent!.children.contains(where: { $0.didRunThisTime })
            if !hasDidRunThisTimeChildren {
                thisSectionIteration.isRunning = true
                try routine()
                thisSectionIteration.isRunning = false
                thisSectionIteration.didRunThisTime = true
                thisSectionIteration.runCount += 1
            }
        }
    }
}

class SectionsTest: XCTestCase {

    func test3Levels3_3Sections() throws {
        var testCaseCallsCount = 0
        var section0CallsCount = 0
        var section1CallsCount = 0
        var section2CallsCount = 0
        var section00CallsCount = 0
        var section01CallsCount = 0
        var section02CallsCount = 0
        var section10CallsCount = 0
        var section11CallsCount = 0
        var section12CallsCount = 0
        var section20CallsCount = 0
        var section21CallsCount = 0
        var section22CallsCount = 0
        var text = ""
        try testCase(#function, routine: {
            testCaseCallsCount += 1
            text += "0"
            try section("0", routine: {
                section0CallsCount += 1
                text += "1"
                try section("00", routine: {
                    section00CallsCount += 1
                    text += "2"
                })
                try section("01", routine: {
                    section01CallsCount += 1
                    text += "3"
                })
                try section("02", routine: {
                    section02CallsCount += 1
                    text += "4"
                })
            })
            try section("1", routine: {
                section1CallsCount += 1
                text += "5"
                try section("10", routine: {
                    section10CallsCount += 1
                    text += "6"
                })
                try section("11", routine: {
                    section11CallsCount += 1
                    text += "7"
                })
                try section("12", routine: {
                    section12CallsCount += 1
                    text += "8"
                })
            })
            try section("2", routine: {
                section2CallsCount += 1
                text += "9"
                try section("20", routine: {
                    section20CallsCount += 1
                    text += "a"
                })
                try section("21", routine: {
                    section21CallsCount += 1
                    text += "b"
                })
                try section("22", routine: {
                    section22CallsCount += 1
                    text += "c"
                })
            })
        })
        XCTAssertEqual(text, "01201301405605705809a09b09c")
        XCTAssertEqual(section0CallsCount, 3)
        XCTAssertEqual(section1CallsCount, 3)
        XCTAssertEqual(section2CallsCount, 3)
        XCTAssertEqual(section00CallsCount, 1)
        XCTAssertEqual(section01CallsCount, 1)
        XCTAssertEqual(section02CallsCount, 1)
        XCTAssertEqual(section10CallsCount, 1)
        XCTAssertEqual(section11CallsCount, 1)
        XCTAssertEqual(section12CallsCount, 1)
        XCTAssertEqual(section20CallsCount, 1)
        XCTAssertEqual(section21CallsCount, 1)
        XCTAssertEqual(section22CallsCount, 1)
        XCTAssertEqual(testCaseCallsCount, 9)
    }

    func test2Levels2_2Sections() throws {
        var testCaseCallsCount = 0
        var section0CallsCount = 0
        var section1CallsCount = 0
        var section00CallsCount = 0
        var section01CallsCount = 0
        var section10CallsCount = 0
        var section11CallsCount = 0
        var text = ""
        try testCase(#function, routine: {
            testCaseCallsCount += 1
            text += "0"
            try section("0", routine: {
                section0CallsCount += 1
                text += "1"
                try section("00", routine: {
                    section00CallsCount += 1
                    text += "2"
                })
                try section("01", routine: {
                    section01CallsCount += 1
                    text += "3"
                })
            })
            try section("1", routine: {
                section1CallsCount += 1
                text += "4"
                try section("10", routine: {
                    section10CallsCount += 1
                    text += "5"
                })
                try section("11", routine: {
                    section11CallsCount += 1
                    text += "6"
                })
            })
        })
        XCTAssertEqual(text, "012013045046")
        XCTAssertEqual(section10CallsCount, 1)
        XCTAssertEqual(section11CallsCount, 1)
        XCTAssertEqual(section00CallsCount, 1)
        XCTAssertEqual(section01CallsCount, 1)
        XCTAssertEqual(section1CallsCount, 2)
        XCTAssertEqual(section0CallsCount, 2)
        XCTAssertEqual(testCaseCallsCount, 4)
    }

    func test2Levels1_2Sections() throws {
        var testCaseCallsCount = 0
        var section0CallsCount = 0
        var section00CallsCount = 0
        var section01CallsCount = 0
        var text = ""
        try testCase(#function, routine: {
            testCaseCallsCount += 1
            text += "0"
            try section("0", routine: {
                section0CallsCount += 1
                text += "1"
                try section("00", routine: {
                    section00CallsCount += 1
                    text += "2"
                })
                try section("01", routine: {
                    section01CallsCount += 1
                    text += "3"
                })
            })
        })
        XCTAssertEqual(text, "012013")
        XCTAssertEqual(testCaseCallsCount, 2)
        XCTAssertEqual(section0CallsCount, 2)
        XCTAssertEqual(section00CallsCount, 1)
        XCTAssertEqual(section01CallsCount, 1)
    }

    func test2Levels1Section() throws {
        var testCaseCallsCount = 0
        var section0CallsCount = 0
        var section00CallsCount = 0
        var text = ""
        try testCase(#function, routine: {
            testCaseCallsCount += 1
            text += "0"
            try section("0", routine: {
                section0CallsCount += 1
                text += "1"
                try section("00", routine: {
                    section00CallsCount += 1
                    text += "2"
                })
            })
        })
        XCTAssertEqual(text, "012")
        XCTAssertEqual(testCaseCallsCount, 1)
        XCTAssertEqual(section0CallsCount, 1)
        XCTAssertEqual(section00CallsCount, 1)
    }

    func test1Level4Sections() throws {
        var testCaseCallsCount = 0
        var section0CallsCount = 0
        var section1CallsCount = 0
        var section2CallsCount = 0
        var section3CallsCount = 0
        var text = ""
        try testCase(#function, routine: {
            testCaseCallsCount += 1
            text += "0"
            try section("0", routine: {
                section0CallsCount += 1
                text += "1"
            })
            try section("1", routine: {
                section1CallsCount += 1
                text += "2"
            })
            try section("2", routine: {
                section2CallsCount += 1
                text += "3"
            })
            try section("3", routine: {
                section3CallsCount += 1
                text += "4"
            })
        })
        XCTAssertEqual(testCaseCallsCount, 4)
        XCTAssertEqual(section0CallsCount, 1)
        XCTAssertEqual(section1CallsCount, 1)
        XCTAssertEqual(section2CallsCount, 1)
        XCTAssertEqual(section3CallsCount, 1)
        XCTAssertEqual(text, "01020304")
    }

    func test1Level3Sections() throws {
        var testCaseCallsCount = 0
        var section0CallsCount = 0
        var section1CallsCount = 0
        var section2CallsCount = 0
        var text = ""
        try testCase(#function, routine: {
            testCaseCallsCount += 1
            text += "0"
            try section("0", routine: {
                section0CallsCount += 1
                text += "1"
            })
            try section("1", routine: {
                section1CallsCount += 1
                text += "2"
            })
            try section("2", routine: {
                section2CallsCount += 1
                text += "3"
            })
        })
        XCTAssertEqual(testCaseCallsCount, 3)
        XCTAssertEqual(section0CallsCount, 1)
        XCTAssertEqual(section1CallsCount, 1)
        XCTAssertEqual(section2CallsCount, 1)
        XCTAssertEqual(text, "010203")
    }

    func test1Level2Sections() throws {
        var testCaseCallsCount = 0
        var section0CallsCount = 0
        var section1CallsCount = 0
        var text = ""
        try testCase(#function, routine: {
            testCaseCallsCount += 1
            text += "0"
            try section("0", routine: {
                section0CallsCount += 1
                text += "1"
            })
            try section("1", routine: {
                section1CallsCount += 1
                text += "2"
            })
        })
        XCTAssertEqual(text, "0102")
        XCTAssertEqual(testCaseCallsCount, 2)
        XCTAssertEqual(section0CallsCount, 1)
        XCTAssertEqual(section1CallsCount, 1)
    }
}
