//
// CoreDataCandy
// Copyright © 2018-present Amaris Software.
// MIT license, see LICENSE file for details

import CoreData

public extension DatabaseModel {

    /// Current value for the given parent's field
    func current<P: ParentInterfaceProtocol, F: FieldInterfaceProtocol>(_ parentKeyPath: KeyPath<Self, P>, _ valueKeyPath: KeyPath<P.ParentModel, F>)
    -> F.Value?
    where P.Entity == Entity, F.Entity == P.ParentModel.Entity {
        self[keyPath: parentKeyPath].current(valueKeyPath, on: entity)
    }

    /// Current value for the given parent's field
    func current<P: ParentInterfaceProtocol, F: FieldInterfaceProtocol>(_ parentKeyPath: KeyPath<Self, P>, _ valueKeyPath: KeyPath<P.ParentModel, F>)
    -> F.Value
    where P.Entity == Entity, F.Entity == P.ParentModel.Entity, F.Value: ExpressibleByNilLiteral {
        self[keyPath: parentKeyPath].current(valueKeyPath, on: entity)
    }
}
