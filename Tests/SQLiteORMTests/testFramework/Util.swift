import Foundation

func compareUnordered<T>(_ lhs: [T], _ rhs: [T]) -> Bool where T: Equatable {
    guard lhs.count == rhs.count else {
        return false
    }
    for item in lhs {
        guard rhs.contains(where: { $0 == item }) else {
            return false
        }
    }
    return true
}
