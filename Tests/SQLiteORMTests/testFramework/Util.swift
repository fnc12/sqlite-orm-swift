import Foundation

func compareUnordered<T>(_ lhs: [T], _ rhs: [T], _ comparator: ((_ lhs: T, _ rhs: T) -> Bool)) -> Bool {
    guard lhs.count == rhs.count else {
        return false
    }
    for item in lhs {
        guard rhs.contains(where: { comparator($0, item) }) else {
            return false
        }
    }
    return true
}

func compareUnordered<T>(_ lhs: [T], _ rhs: [T]) -> Bool where T: Equatable {
    return compareUnordered(lhs, rhs, { $0 == $1 })
}
