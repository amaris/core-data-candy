//
// Copyright © 2018-present Amaris Software.
//

public extension DatabaseModel {

    /// The current value of the given field
    func current<F: FieldInterfaceProtocol>(_ keyPath: KeyPath<Self, F>)
    throws -> F.Value
    where F.Entity == Entity {
        try self[keyPath: keyPath].currentValue(in: entity)
    }

    /// The current value of the given field
    func current<F: FieldInterfaceProtocol>(_ keyPath: KeyPath<Self, F>, default defaultValue: F.Value)
    -> F.Value
    where F.Entity == Entity {
        do {
            return try self[keyPath: keyPath].currentValue(in: entity)
        } catch {
            return defaultValue
        }
    }

    /// The current value of the given field
    func current<F: FieldInterfaceProtocol>(_ keyPath: KeyPath<Self, F>)
    -> F.Value
    where F.Entity == Entity, F.OutputError == Never {
        self[keyPath: keyPath].currentValue(in: entity)
    }
}
