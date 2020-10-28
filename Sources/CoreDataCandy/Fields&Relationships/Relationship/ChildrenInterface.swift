//
// Copyright © 2018-present Amaris Software.
//

import Foundation
import CoreData
import Combine

/// Relationship one to many
public struct ChildrenInterface<Entity: DatabaseEntity, ChildModel: DatabaseModel>: ChildrenInterfaceProtocol {

    public let keyPath: ReferenceWritableKeyPath<Entity, NSSet?>

    public init(_ keyPath: ReferenceWritableKeyPath<Entity, NSSet?>, as type: ChildModel.Type) {
        self.keyPath = keyPath
    }

    public func mutableSet(from entity: Entity) -> NSMutableSet {
        guard let children = entity[keyPath: keyPath]?.mutableCopy() as? NSMutableSet else {
            assertionFailure("Unable to get a 'NSMutableSet' from the 'NSSet' for \(String(describing: Entity.self)) \(String(describing: ChildModel.self))")
            return NSMutableSet()
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
}

extension ChildrenInterface: FieldPublisher where Entity: NSManagedObject {

    public typealias Value = Set<ChildModel>
    public typealias OutputError = Never

    public func publisher(for entity: Entity) -> AnyPublisher<Set<ChildModel>, Never> {
        entity.attributePublisher(for: keyPath)
            .map { $0 as? Value ?? [] }
            .eraseToAnyPublisher()
    }
}

public extension DatabaseModel {
    typealias Children<ChildModel: DatabaseModel> = ChildrenInterface<Entity, ChildModel>
}
