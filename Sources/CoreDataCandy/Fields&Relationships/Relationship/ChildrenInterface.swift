//
// Copyright © 2018-present Amaris Software.
//

import Foundation
import Combine

/// Relationship one to many
public struct ChildrenInterface<Entity: DatabaseEntity, ChildModel: DatabaseModel> {

    let keyPath: ReferenceWritableKeyPath<Entity, NSSet?>

    init(_ keyPath: ReferenceWritableKeyPath<Entity, NSSet?>, as type: ChildModel.Type) {
        self.keyPath = keyPath
    }
}

extension ChildrenInterface: FieldPublisher {

    public typealias Value = Set<ChildModel>
    public typealias OutputError = Never

    public func publisher(for entity: Entity) -> AnyPublisher<Set<ChildModel>, Never> {
        entity.attributePublisher(for: keyPath)
            .map { $0 as? Value ?? [] }
            .eraseToAnyPublisher()
    }
}

extension DatabaseModel {

    public typealias Children<ChildModel: DatabaseModel> = ChildrenInterface<Entity, ChildModel>
}
