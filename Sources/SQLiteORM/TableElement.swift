import Foundation

public protocol TableElementProtocol {
    var tableElement: TableElement { get }
}

public enum TableElement {
    case column(column: AnyColumn)
}
