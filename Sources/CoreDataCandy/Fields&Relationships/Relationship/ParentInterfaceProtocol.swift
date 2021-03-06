//
// CoreDataCandy
// Copyright © 2018-present Amaris Software.
// MIT license, see LICENSE file for details

import CoreData

/// Protocol with no requirements to offer functions on Parent and Sibling relationships
public protocol ParentInterfaceProtocol {
    associatedtype Entity: DatabaseEntity
    associatedtype ParentModel: DatabaseModel

    var keyPath: ReferenceWritableKeyPath<Entity, ParentModel.Entity?> { get }
}

public extension ParentInterfaceProtocol where ParentModel.Entity: NSManagedObject {

    /// The current value of the given parent model's field
    func current<F: FieldInterfaceProtocol>(_ keyPath: KeyPath<ParentModel, F>, on entity: Entity)
    -> F.Value?
    where ParentModel.Entity == F.Entity {
        guard let parentEntity = entity[keyPath: self.keyPath] else { return nil }

        let parent = ParentModel(entity: parentEntity)
        let field = parent[keyPath: keyPath]

        return field.currentValue(in: parentEntity)
    }

    /// The current value of the given parent model's field
    func current<F: FieldInterfaceProtocol>(_ keyPath: KeyPath<ParentModel, F>, on entity: Entity)
    -> F.Value
    where ParentModel.Entity == F.Entity, F.Value: ExpressibleByNilLiteral { // prevent the optional optional
        guard let parentEntity = entity[keyPath: self.keyPath] else { return nil }

        let parent = ParentModel(entity: parentEntity)
        let field = parent[keyPath: keyPath]

        return field.currentValue(in: parentEntity)
    }
}
