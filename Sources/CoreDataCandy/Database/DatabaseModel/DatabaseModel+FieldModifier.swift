//
// Copyright © 2018-present Amaris Software.
//

public extension DatabaseModel {

    /// Assign the output of the upstream to the given field property
    func assign<F: FieldModifier, Value>(_ value: Value, to keyPath: KeyPath<Self, F>)
    throws
    where F.Value == Value, F.Entity == Entity {
        let field = self[keyPath: keyPath]
        try field.set(value, on: entity)
    }

    /// Try to toggle the boolean at the given key path
    func toggle<F: FieldInterfaceProtocol>(_ keyPath: KeyPath<Self, F>)
    throws
    where F.Value == Bool, F.Entity == Entity, F.OutputError == Never {
        let field = self[keyPath: keyPath]
        try field.toggle(on: entity)
    }
}
