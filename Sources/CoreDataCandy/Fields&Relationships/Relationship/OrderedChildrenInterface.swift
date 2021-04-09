//
// CoreDataCandy
// Copyright © 2018-present Amaris Software.
// MIT license, see LICENSE file for details

import CoreData
import Combine

/// Relationship one to many (ordered)
public struct OrderedChildrenInterface<Entity: DatabaseEntity, ChildModel: DatabaseModel>: ChildrenInterfaceProtocol {

    // MARK: - Constants

    public typealias MutableStorage = NSMutableOrderedSet

    // MARK: - Properties

    public let keyPath: ReferenceWritableKeyPath<Entity, NSOrderedSet?>

    // MARK: - Initialisation

    public init(_ keyPath: ReferenceWritableKeyPath<Entity, NSOrderedSet?>, as type: ChildModel.Type) {
        self.keyPath = keyPath
    }

    // MARK: - Functions

    func insert(_ child: ChildModel, at index: Int, on entity: Entity) {
        let children = mutableStorage(from: entity)
        children.insert(child, at: index)
        entity[keyPath: keyPath] = children
    }

    func remove(at index: Int, on entity: Entity) {
        let children = mutableStorage(from: entity)
        children.removeObject(at: index)
        entity[keyPath: keyPath] = children
    }

    func moveElements(at fromIndexesSet: Set<Int>, to toIndex: Int, on entity: Entity) {
        let children = mutableStorage(from: entity)
        let indexSet = IndexSet(fromIndexesSet)
        children.moveObjects(at: indexSet, to: toIndex)
        entity[keyPath: keyPath] = children
    }

    func swapElements(at aIndex: Int, _ bIndex: Int, on entity: Entity) {
        let children = mutableStorage(from: entity)
        children.exchangeObject(at: aIndex, withObjectAt: bIndex)
        entity[keyPath: keyPath] = children
    }
}

extension OrderedChildrenInterface: FieldPublisher where
    Entity: NSManagedObject,
    ChildModel.Entity: NSManagedObject {}

public extension DatabaseModel {

    /// Relationship one to many (ordered)
    typealias OrderedChildren<ChildModel: DatabaseModel> = OrderedChildrenInterface<Entity, ChildModel>
}
