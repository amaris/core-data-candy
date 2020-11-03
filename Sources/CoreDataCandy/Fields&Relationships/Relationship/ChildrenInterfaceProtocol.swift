//
// Copyright © 2018-present Amaris Software.
//

import CoreData
import Combine

/// Holds the logic to access a children (one to many) relationship
public protocol ChildrenInterfaceProtocol {
    associatedtype Entity: DatabaseEntity
    associatedtype ChildModel: DatabaseModel
    associatedtype MutableStorage: RelationMutableStorage

    var keyPath: ReferenceWritableKeyPath<Entity, MutableStorage.Immutable?> { get }

    func add(_ child: ChildModel, on entity: Entity)
    func remove(_ child: ChildModel, on entity: Entity)
}

extension ChildrenInterfaceProtocol {

    public func mutableStorage(from entity: Entity) -> MutableStorage {
        guard let children = entity[keyPath: keyPath]?.mutableCopy() as? MutableStorage else {
            assertionFailure("Unable to get a 'NSMutableSet' from the 'NSSet' for \(String(describing: Entity.self)) \(String(describing: ChildModel.self))")
            return MutableStorage()
        }
        return children
    }

    public func add(_ child: ChildModel, on entity: Entity) {
        let children = mutableStorage(from: entity)
        children.add(child.entity)
        entity[keyPath: keyPath] = children.immutable
    }

    public func remove(_ child: ChildModel, on entity: Entity) {
        let children = mutableStorage(from: entity)
        children.remove(child.entity)
        entity[keyPath: keyPath] = children.immutable
    }
}

extension ChildrenInterfaceProtocol where Entity: NSManagedObject, ChildModel.Entity: NSManagedObject {

    public typealias Output = [ChildModel]
    public typealias OutputError = Never

    public func publisher(for entity: Entity) -> AnyPublisher<Output, Never> {
        entity.publisher(for: keyPath)
            .replaceNil(with: .init())
            .map(\.array)
            .map(childModels)
            .eraseToAnyPublisher()
    }

    func childModels(from entities: [Any]) -> Output {
        entities.map(childModel)
    }

    func childModel(from entity: Any) -> ChildModel {
        guard let entity = entity as? ChildModel.Entity else {
            preconditionFailure("The children are not of type \(ChildModel.Entity.self)")
        }
        return ChildModel(entity: entity)
    }
}

public extension ChildrenInterfaceProtocol where Self: FieldPublisher, Self.Output == [ChildModel], ChildModel.Entity: FetchableEntity {

    func publisher<Value: Comparable>(for entity: Entity, sortedBy sort: Sort<ChildModel.Entity, Value>) -> AnyPublisher<Output, OutputError> {
        publisher(for: entity)
            .sorted(with: sort)
            .eraseToAnyPublisher()
    }
}
