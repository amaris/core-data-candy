//
// Copyright © 2018-present Amaris Software.
//

import Combine
import CoreData

public extension DatabaseModel {

    func current <Children: ChildrenInterfaceProtocol>(_ keyPath: KeyPath<Self, Children>)
    -> [Children.ChildModel]
    where Children.Entity == Entity, Children.Entity: NSManagedObject, Children.ChildModel.Entity: NSManagedObject {
        self[keyPath: keyPath].currentValue(on: entity)
    }

    func add<Children: ChildrenInterfaceProtocol>(_ child: Children.ChildModel, to childrenKeyPath: KeyPath<Self, Children>)
    throws
    where Children.Entity == Entity {
        let childrenInterface = self[keyPath: childrenKeyPath]
        childrenInterface.add(child, on: entity)
    }

    func remove<Children: ChildrenInterfaceProtocol>(_ child: Children.ChildModel, to childrenKeyPath: KeyPath<Self, Children>)
    throws
    where Children.Entity == Entity {
        let childrenInterface = self[keyPath: childrenKeyPath]
        childrenInterface.remove(child, on: entity)
    }
}

public extension DatabaseModel where Entity: FetchableEntity {

    /// Publisher for the given relationship
    /// - Parameters:
    ///   - keyPath: The children to observe
    ///   - sorts: Sorts to be applied to the emitted array
    /// - Returns: An array of the children
    func publisher<F: FieldPublisher & ChildrenInterfaceProtocol>(
        for keyPath: KeyPath<Self, F>,
        sortedBy sorts: Sort<F.ChildModel.Entity>...)
    -> AnyPublisher<F.Output, Never>
    where F.Entity == Entity, F.Output == [F.ChildModel], F.ChildModel.Entity: FetchableEntity {
        self[keyPath: keyPath].publisher(for: entity, sortedBy: sorts)
    }
}
