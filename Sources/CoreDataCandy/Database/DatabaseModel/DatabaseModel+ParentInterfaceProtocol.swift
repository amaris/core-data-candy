//
// CoreDataCandy
// Copyright © 2018-present Amaris Software.
// MIT license, see LICENSE file for details

import CoreData

public extension DatabaseModel {

    func current<P: ParentInterfaceProtocol, F: FieldInterfaceProtocol>(_ parentKeyPath: KeyPath<Self, P>, _ valueKeyPath: KeyPath<P.ParentModel, F>)
    -> F.Value?
    where P.Entity == Entity, F.Entity == P.ParentModel.Entity {
        self[keyPath: parentKeyPath].current(valueKeyPath, on: entity)
    }

    func current<P: ParentInterfaceProtocol, F: FieldInterfaceProtocol>(_ parentKeyPath: KeyPath<Self, P>, _ valueKeyPath: KeyPath<P.ParentModel, F>)
    -> F.Value
    where P.Entity == Entity, F.Entity == P.ParentModel.Entity, F.Value: ExpressibleByNilLiteral {
        self[keyPath: parentKeyPath].current(valueKeyPath, on: entity)
    }

    func current<P: ParentInterfaceProtocol>(_ keyPath: KeyPath<Self, P>)
    -> P.ParentModel?
    where P.Entity == Entity {

        let parentKeyPath = self[keyPath: keyPath].keyPath
        guard let parentEntity = entity[keyPath: parentKeyPath] else {
            return nil
        }
        return P.ParentModel(entity: parentEntity)
    }
}
