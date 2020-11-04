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

    /// Try to get the current stored value in the entity
    func currentValue(in entity: Entity) throws -> Value

    func validate(_ value: Value) throws
}

public extension FieldModifier where Value == Bool {

    func toggle(on entity: Entity) throws {
        let flag = try currentValue(in: entity)
        try set(!flag, on: entity)
    }
}
