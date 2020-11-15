//
// Copyright © 2018-present Amaris Software.
//

import CoreData

/// Can modify a CoreData entity field/attribute
public protocol FieldModifier {
    associatedtype Entity: DatabaseEntity
    associatedtype Value

    /// Store the value in the entity after validating it
    func set(_ value: Value, on entity: Entity) throws

    func validate(_ value: Value) throws
}

public extension FieldModifier where Self: FieldInterfaceProtocol, Self.StoreConversionError == Never, Value == Bool {

    func toggle(on entity: Entity) throws {
        let flag = currentValue(in: entity)
        try set(!flag, on: entity)
    }
}
