import Foundation

public func abs(_ x: Expression) -> BuiltInFunction {
    return .abs(x: x)
}

public func changes() -> BuiltInFunction {
    return .changes
}

public func char(_ arguments: Expression...) -> BuiltInFunction {
    return .char(arguments: arguments)
}

public func coalesce(_ x: Expression, _ y: Expression, _ rest: Expression...) -> BuiltInFunction {
    return .coalesce(arguments: [x, y] + rest)
}

public func glob(_ x: Expression, _ y: Expression) -> BuiltInFunction {
    return .glob(x: x, y: y)
}

public func format(_ f: Expression, _ rest: Expression...) -> BuiltInFunction {
    return .format(arguments: [f] + rest)
}

public func hex(_ x: Expression) -> BuiltInFunction {
    return .hex(x: x)
}

public func ifnull(_ x: Expression, _ y: Expression) -> BuiltInFunction {
    return .ifnull(x: x, y: y)
}

public func iif(_ x: Expression, _ y: Expression, _ z: Expression) -> BuiltInFunction {
    return .iif(x: x, y: y, z: z)
}

public func instr(_ x: Expression, _ y: Expression) -> BuiltInFunction {
    return .instr(x: x, y: y)
}

public func lastInsertRowid() -> BuiltInFunction {
    return .lastInsertRowid
}

public func length(_ x: Expression) -> BuiltInFunction {
    return .length(x: x)
}

public func like(_ x: Expression, _ y: Expression) -> BuiltInFunction {
    return .like2(x: x, y: y)
}

public func like(_ x: Expression, _ y: Expression, _ z: Expression) -> BuiltInFunction {
    return .like3(x: x, y: y, z: z)
}

public func likelihood(_ x: Expression, _ y: Expression) -> BuiltInFunction {
    return .likelihood(x: x, y: y)
}

public func likely(_ x: Expression) -> BuiltInFunction {
    return .likely(x: x)
}

public func loadExtension(_ x: Expression) -> BuiltInFunction {
    return .loadExtension1(x: x)
}

public func loadExtension(_ x: Expression, _ y: Expression) -> BuiltInFunction {
    return .loadExtension2(x: x, y: y)
}

public func lower(_ x: Expression) -> BuiltInFunction {
    return .lower(x: x)
}

public func ltrim(_ x: Expression) -> BuiltInFunction {
    return .ltrim1(x: x)
}

public func ltrim(_ x: Expression, _ y: Expression) -> BuiltInFunction {
    return .ltrim2(x: x, y: y)
}

public func max(_ x: Expression, _ y: Expression, _ rest: Expression...) -> BuiltInFunction {
    return .max(arguments: [x, y] + rest)
}

public func min(_ x: Expression, _ y: Expression, _ rest: Expression...) -> BuiltInFunction {
    return .min(arguments: [x, y] + rest)
}

public func nullif(_ x: Expression, _ y: Expression) -> BuiltInFunction {
    return .nullif(x: x, y: y)
}

public func printf(_ format: Expression, _ rest: Expression...) -> BuiltInFunction {
    return .printf(argruments: [format] + rest)
}

public func random() -> BuiltInFunction {
    return .random
}

public func randomblob(_ x: Expression) -> BuiltInFunction {
    return .randomblob(x: x)
}

public func replace(_ x: Expression, _ y: Expression, _ z: Expression) -> BuiltInFunction {
    return .replace(x: x, y: y, z: z)
}

public func round(_ x: Expression) -> BuiltInFunction {
    return .round1(x: x)
}

public func round(_ x: Expression, _ y: Expression) -> BuiltInFunction {
    return .round2(x: x, y: y)
}

public func rtrim(_ x: Expression) -> BuiltInFunction {
    return .rtrim1(x: x)
}

public func rtrim(_ x: Expression, _ y: Expression) -> BuiltInFunction {
    return .rtrim2(x: x, y: y)
}

public func sign(_ x: Expression) -> BuiltInFunction {
    return .sign(x: x)
}

public func soundex(_ x: Expression) -> BuiltInFunction {
    return .soundex(x: x)
}

public func sqliteCompileOptionGet(_ x: Expression) -> BuiltInFunction {
    return .sqliteCompileOptionGet(x: x)
}

public func sqliteCompileOptionUsed(_ x: Expression) -> BuiltInFunction {
    return .sqliteCompileOptionUsed(x: x)
}

public func sqliteOffset(_ x: Expression) -> BuiltInFunction {
    return .sqliteOffset(x: x)
}

public func sqliteSourceId() -> BuiltInFunction {
    return .sqliteSourceId
}

public func sqliteVersion() -> BuiltInFunction {
    return .sqliteVersion
}

public func substr(_ x: Expression, _ y: Expression, _ z: Expression) -> BuiltInFunction {
    return .substr3(x: x, y: y, z: z)
}

public func substr(_ x: Expression, _ y: Expression) -> BuiltInFunction {
    return .substr2(x: x, y: y)
}

public func substring(_ x: Expression, _ y: Expression, _ z: Expression) -> BuiltInFunction {
    return .substring3(x: x, y: y, z: z)
}

public func substring(_ x: Expression, _ y: Expression) -> BuiltInFunction {
    return .substring2(x: x, y: y)
}

public func totalChanges() -> BuiltInFunction {
    return .totalChanges
}

public func trim(_ x: Expression) -> BuiltInFunction {
    return .trim1(x: x)
}

public func trim(_ x: Expression, _ y: Expression) -> BuiltInFunction {
    return .trim2(x: x, y: y)
}

public func typeof(_ x: Expression) -> BuiltInFunction {
    return .typeof(x: x)
}

public func unicode(_ x: Expression) -> BuiltInFunction {
    return .unicode(x: x)
}

public func unlikely(_ x: Expression) -> BuiltInFunction {
    return .unlikely(x: x)
}

public func upper(_ x: Expression) -> BuiltInFunction {
    return .upper(x: x)
}

public func zeroblob(_ x: Expression) -> BuiltInFunction {
    return .zeroblob(x: x)
}
