//
// Copyright © 2018-present Amaris Software.
//

import Foundation
import Combine

/// Relationship one to many (ordered)
public struct OrderedChildrenInterface<Entity: DatabaseEntity, ChildModel: DatabaseModel> {

    let keyPath: ReferenceWritableKeyPath<Entity, NSOrderedSet?>

    init(_ type: ChildModel.Type, _ keyPath: ReferenceWritableKeyPath<Entity, NSOrderedSet?>) {
        self.keyPath = keyPath
    }
}

extension OrderedChildrenInterface: FieldPublisher {

    public typealias Value = [ChildModel]
    public typealias OutputError = Never

    public func publisher(for entity: Entity) -> AnyPublisher<[ChildModel], Never> {
        entity.attributePublisher(for: keyPath)
            .map { $0?.array as? Value ?? [] }
            .eraseToAnyPublisher()
    }
}

extension DatabaseModel {

    public typealias OrderedChildren<ChildModel: DatabaseModel> = OrderedChildrenInterface<Entity, ChildModel>
}
