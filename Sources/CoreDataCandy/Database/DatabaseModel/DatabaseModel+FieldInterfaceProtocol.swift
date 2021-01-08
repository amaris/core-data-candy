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

public extension Collection where Element: DatabaseModel {

    /// Map the current value of the field
    func mapCurrent<F: FieldInterfaceProtocol>(_ keyPath: KeyPath<Element, F>) -> [F.Value] where Element.Entity == F.Entity {
        map { $0.current(keyPath) }
    }

    /// FlatMap the current value of the field
    func flatMapCurrent<F: FieldInterfaceProtocol, E>(_ keyPath: KeyPath<Element, F>) -> [E] where Element.Entity == F.Entity, F.Value == [E] {
        flatMap { $0.current(keyPath) }
    }

    /// CompactMap the current value of the field
    func compactMapCurrent<F: FieldInterfaceProtocol, E>(_ keyPath: KeyPath<Element, F>) -> [E] where Element.Entity == F.Entity, F.Value == E? {
        compactMap { $0.current(keyPath) }
    }
}
