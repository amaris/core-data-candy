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

    func add<Children: ChildrenInterfaceProtocol>(_ child: Children.ChildModel, in childrenKeyPath: KeyPath<Self, Children>)
    throws
    where Children.Entity == Entity {
        let childrenInterface = self[keyPath: childrenKeyPath]
        childrenInterface.add(child, on: entity)
    }

    func remove<Children: ChildrenInterfaceProtocol>(_ child: Children.ChildModel, in childrenKeyPath: KeyPath<Self, Children>)
    throws
    where Children.Entity == Entity {
        let childrenInterface = self[keyPath: childrenKeyPath]
        childrenInterface.remove(child, on: entity)
    }
}

public extension DatabaseModel where Entity: FetchableEntity {

    /// Publisher for the given relationship
    func publisher<F: FieldPublisher & ChildrenInterfaceProtocol, Criteria>(
        for keyPath: KeyPath<Self, F>,
        sortedBy sort: Sort<F.ChildModel.Entity, Criteria>)
    -> AnyPublisher<F.Output, Never>
    where F.Entity == Entity, F.Output == [F.ChildModel] {
        self[keyPath: keyPath].publisher(for: entity, sortedBy: sort)
    }
}
