//
// CoreDataCandy
// Copyright © 2018-present Amaris Software.
// MIT license, see LICENSE file for details

public extension DatabaseModel {

    func validate<F: FieldModifier>(_ value: F.Value, for keyPath: KeyPath<Self, F>) throws
    where F.Entity == Entity {
        try self[keyPath: keyPath].validate(value)
    }

    func assign<F: FieldModifier>(_ value: F.Value, to keyPath: KeyPath<Self, F>)
    where F.Entity == Entity {
        self[keyPath: keyPath].set(value, on: entity)
    }

    func validateAndAssign<F: FieldModifier>(_ value: F.Value, to keyPath: KeyPath<Self, F>) throws
    where F.Entity == Entity {
        try validate(value, for: keyPath)
        assign(value, to: keyPath)
    }

    func toggle<F: FieldInterfaceProtocol>(_ keyPath: KeyPath<Self, F>)
    where F.Value == Bool, F.Entity == Entity {
        self[keyPath: keyPath].toggle(on: entity)
    }
}
