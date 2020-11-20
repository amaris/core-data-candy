//
// CoreDataCandy
// Copyright © 2018-present Amaris Software.
// MIT license, see LICENSE file for details

public extension DatabaseModel {

    /// The current value of the given field
    func current<F: FieldInterfaceProtocol>(_ keyPath: KeyPath<Self, F>) -> F.Value
    where F.Entity == Entity {
        self[keyPath: keyPath].currentValue(in: entity)
    }

    /// The current value of the given field
    func current<F: FieldInterfaceProtocol>(_ keyPath: KeyPath<Self, F>) -> F.Value
    where F.Entity == Entity, F.FieldValue: ExpressibleByNilLiteral, F.Value: ExpressibleByNilLiteral {
        self[keyPath: keyPath].currentValue(in: entity)
    }
}
