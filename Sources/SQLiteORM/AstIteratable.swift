import Foundation

public protocol AstIteratable: Any {
    func iterateAst(routine: (_ expression: Expression) -> Void)
}

extension Int: AstIteratable {
    public func iterateAst(routine: (Expression) -> Void) {
        routine(self)
    }
}

extension UInt: AstIteratable {
    public func iterateAst(routine: (Expression) -> Void) {
        routine(self)
    }
}

extension Int64: AstIteratable {
    public func iterateAst(routine: (Expression) -> Void) {
        routine(self)
    }
}

extension UInt64: AstIteratable {
    public func iterateAst(routine: (Expression) -> Void) {
        routine(self)
    }
}

extension Bool: AstIteratable {
    public func iterateAst(routine: (Expression) -> Void) {
        routine(self)
    }
}

extension String: AstIteratable {
    public func iterateAst(routine: (Expression) -> Void) {
        routine(self)
    }
}

extension KeyPath: AstIteratable {
    public func iterateAst(routine: (Expression) -> Void) {
        routine(self)
    }
}

extension Float: AstIteratable {
    public func iterateAst(routine: (Expression) -> Void) {
        routine(self)
    }
}

extension Double: AstIteratable {
    public func iterateAst(routine: (Expression) -> Void) {
        routine(self)
    }
}
