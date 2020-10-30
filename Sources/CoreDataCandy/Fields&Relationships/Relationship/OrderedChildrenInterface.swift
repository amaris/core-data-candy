//
// Copyright © 2018-present Amaris Software.
//

import CoreData
import Combine

/// Relationship one to many (ordered)
public struct OrderedChildrenInterface<Entity: DatabaseEntity, ChildModel: DatabaseModel>: ChildrenInterfaceProtocol {

    let keyPath: ReferenceWritableKeyPath<Entity, NSOrderedSet?>

    public init(_ keyPath: ReferenceWritableKeyPath<Entity, NSOrderedSet?>, as type: ChildModel.Type) {
        self.keyPath = keyPath
    }

    public func mutableSet(from entity: Entity) -> NSMutableOrderedSet {
        guard let children = entity[keyPath: keyPath]?.mutableCopy() as? NSMutableOrderedSet else {
            assertionFailure("Unable to get a 'NSMutableSet' from the 'NSSet' for \(String(describing: Entity.self)) \(String(describing: ChildModel.self))")
            return NSMutableOrderedSet()
        }
        return children
    }

    public func add(_ child: ChildModel, on entity: Entity) {
        let children = mutableSet(from: entity)
        children.add(child.entity)
        entity[keyPath: keyPath] = children
    }

    public func remove(_ child: ChildModel, on entity: Entity) {
        let children = mutableSet(from: entity)
        children.remove(child.entity)
        entity[keyPath: keyPath] = children
    }

    func insert(_ child: ChildModel, at index: Int, on entity: Entity) {
        let children = mutableSet(from: entity)
        children.insert(child, at: index)
        entity[keyPath: keyPath] = children
    }

    func remove(at index: Int, on entity: Entity) {
        let children = mutableSet(from: entity)
        children.removeObject(at: index)
        entity[keyPath: keyPath] = children
    }
}

extension OrderedChildrenInterface: FieldPublisher where Entity: NSManagedObject {

    public typealias Value = [ChildModel]
    public typealias OutputError = Never

    public func publisher(for entity: Entity) -> AnyPublisher<Value, Never> {
        entity.publisher(for: keyPath)
            .map { $0?.array as? Value ?? [] }
            .eraseToAnyPublisher()
    }
}

public extension DatabaseModel {
    typealias OrderedChildren<ChildModel: DatabaseModel> = OrderedChildrenInterface<Entity, ChildModel>
}
