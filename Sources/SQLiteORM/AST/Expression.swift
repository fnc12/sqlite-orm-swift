import Foundation

public protocol Expression: Serializable {
    
}

extension Int: Expression {
    
}

extension Bool: Expression {
    
}

extension String: Expression {
    
}

extension KeyPath: Expression {
    
}
