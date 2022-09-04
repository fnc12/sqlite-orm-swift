import Foundation

public struct AssignList {
    var assigns: [BinaryOperator]

    init(assigns: [BinaryOperator]) {
        self.assigns = assigns
    }
}

extension AssignList: Serializable {
    public func serialize(with serializationContext: SerializationContext) -> Result<String, Error> {
        var res = "SET"
        let assignsCount = self.assigns.count
        let newSerializationContext = serializationContext.bySkippingTableName()
        for (index, assign) in self.assigns.enumerated() {
            switch assign.serialize(with: newSerializationContext) {
            case .success(let assignString):
                res += " \(assignString)"
                if index < assignsCount - 1 {
                    res += ","
                }
            case .failure(let error):
                return .failure(error)
            }
        }
        return .success(res)
    }
}

public func set(_ assigns: BinaryOperator...) -> AssignList {
    return .init(assigns: assigns)
}
