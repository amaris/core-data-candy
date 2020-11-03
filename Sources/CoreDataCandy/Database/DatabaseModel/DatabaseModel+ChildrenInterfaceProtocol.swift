//
// Copyright © 2018-present Amaris Software.
//

import Combine
import CoreData

public extension DatabaseModel {

    func add<Children: ChildrenInterfaceProtocol>(_ child: Children.ChildModel, in childrenKeyPath: KeyPath<Self, Children>)
    throws
    where Children.Entity == Entity {
        let childrenInterface = self[keyPath: childrenKeyPath]
        childrenInterface.add(child, on: entity)
        try saveEntityContext()
    }

    func remove<Children: ChildrenInterfaceProtocol>(_ child: Children.ChildModel, in childrenKeyPath: KeyPath<Self, Children>)
    throws
    where Children.Entity == Entity {
        let childrenInterface = self[keyPath: childrenKeyPath]
        childrenInterface.remove(child, on: entity)
        try saveEntityContext()
    }

    /// Publisher for the given relationship
    func publisher<Error, F: FieldPublisher & ChildrenInterfaceProtocol, Criteria: Comparable>
    (for keyPath: KeyPath<Self, F>, sortedBy sort: Sort<F.ChildModel.Entity, Criteria>)
    -> AnyPublisher<F.Output, Error>
    where Error == F.OutputError, F.Entity == Entity, F.Output == [F.ChildModel], F.ChildModel.Entity: FetchableEntity {
        self[keyPath: keyPath].publisher(for: entity, sortedBy: sort)
    }
}
