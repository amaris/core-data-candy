//
// Copyright © 2018-present Amaris Software.
//

public extension DatabaseModel {

    /// Validate the value for the given field property, throwing a relevant error if the value is invalidated
    func validate<F: FieldModifier, Value>(_ value: Value, for keyPath: KeyPath<Self, F>) throws
    where F.Value == Value, F.Entity == Entity {
        try self[keyPath: keyPath].validate(value)
    }

    /// Assign the value to the given field property
    func assign<F: FieldModifier, Value>(_ value: Value, to keyPath: KeyPath<Self, F>)
    where F.Value == Value, F.Entity == Entity {
        self[keyPath: keyPath].set(value, on: entity)
    }

    /// Validate the value for the given field property then assign it, throwing a relevant error if the value is invalidated
    func validateAndAssign<F: FieldModifier, Value>(_ value: Value, to keyPath: KeyPath<Self, F>) throws
    where F.Value == Value, F.Entity == Entity {
        try validate(value, for: keyPath)
        assign(value, to: keyPath)
    }

    /// Try to toggle the boolean at the given key path
    func toggle<F: FieldInterfaceProtocol>(_ keyPath: KeyPath<Self, F>)
    where F.Value == Bool, F.Entity == Entity {
        self[keyPath: keyPath].toggle(on: entity)
    }
}
