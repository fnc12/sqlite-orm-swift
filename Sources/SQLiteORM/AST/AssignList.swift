import Foundation

public struct AssignList {
    var assigns: [BinaryOperator]

    init(assigns: [BinaryOperator]) {
        self.assigns = assigns
    }
}

extension AssignList: Serializable {
    public func serialize(with serializationContext: SerializationContext) throws -> String {
        var res = "SET"
        let assignsCount = self.assigns.count
        let newSerializationContext = serializationContext.bySkippingTableName()
        for (index, assign) in self.assigns.enumerated() {
            res += " \(try assign.serialize(with: newSerializationContext))"
            if index < assignsCount - 1 {
                res += ","
            }
        }
        return res
    }
}

public func set(_ assigns: BinaryOperator...) -> AssignList {
    return .init(assigns: assigns)
}
