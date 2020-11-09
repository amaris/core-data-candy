//
// Copyright © 2018-present Amaris Software.
//

import CoreData

/// Protocol with no requirements to offer functions on Parent and Sibling relationships
public protocol ParentInterfaceProtocol {
    associatedtype Entity: DatabaseEntity
    associatedtype ParentModel: DatabaseModel

    var keyPath: ReferenceWritableKeyPath<Entity, ParentModel.Entity?> { get }
}

public extension ParentInterfaceProtocol where ParentModel.Entity: NSManagedObject {

    /// The current value of the given parent model's field
    func current<Value>(_ keyPath: KeyPath<ParentModel.Entity, Value>, on entity: Entity) -> Value? {
        guard let parent = entity[keyPath: self.keyPath] else {
            return nil
        }

        return parent[keyPath: keyPath]
    }

    /// The current value of the given parent model's field
    func current<Value>(_ keyPath: KeyPath<ParentModel.Entity, Value?>, on entity: Entity) -> Value? {
        guard
            let parent = entity[keyPath: self.keyPath],
            let value = parent[keyPath: keyPath]
        else {
            return nil
        }

        return value
    }
}
