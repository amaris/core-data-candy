//
// Copyright © 2018-present Amaris Software.
//

public extension DatabaseModel {

    /// The current value of the given field
    func current<F: FieldInterfaceProtocol>(_ keyPath: KeyPath<Self, F>) throws -> F.Value
    where F.Entity == Entity {
        try self[keyPath: keyPath].currentValue(in: _entityWrapper.entity)
    }

    func current<F: FieldInterfaceProtocol>(_ keyPath: KeyPath<Self, F>, default defaultValue: F.Value) -> F.Value
    where F.Entity == Entity {
        do {
            return try self[keyPath: keyPath].currentValue(in: _entityWrapper.entity)
        } catch {
            return defaultValue
        }
    }

    /// The current value of the given field
    func current<F: FieldInterfaceProtocol>(_ keyPath: KeyPath<Self, F>) -> F.Value
    where F.Entity == Entity, F.OutputError == Never {
        self[keyPath: keyPath].currentValue(in: _entityWrapper.entity)
    }

    /// Assign the output of the upstream to the given field property
    func assign<F: FieldModifier, Value>(_ value: Value, to keyPath: KeyPath<Self, F>)
    throws
    where F.Value == Value, F.Entity == Entity {
        let field = self[keyPath: keyPath]
        try field.set(value, on: _entityWrapper.entity)
    }

    /// Try to toggle the boolean at the given key path
    func toggle<F: FieldInterfaceProtocol>(_ keyPath: KeyPath<Self, F>)
    throws
    where F.Value == Bool, F.Entity == Entity, F.OutputError == Never {
        let field = self[keyPath: keyPath]
        try field.toggle(on: _entityWrapper.entity)
    }
}
