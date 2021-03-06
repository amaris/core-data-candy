//
// CoreDataCandy
// Copyright © 2018-present Amaris Software.
// MIT license, see LICENSE file for details

import CoreData

/// Can modify a CoreData entity field/attribute
public protocol FieldModifier {
    associatedtype Entity: DatabaseEntity
    associatedtype Value

    /// Store the value in the entity after validating it
    func set(_ value: Value, on entity: Entity)

    /// Validate the value for the field
    func validate(_ value: Value) throws
}

public extension FieldModifier where Self: FieldInterfaceProtocol, Value == Bool {

    func toggle(on entity: Entity) {
        let flag = currentValue(in: entity)
        set(!flag, on: entity)
    }
}
