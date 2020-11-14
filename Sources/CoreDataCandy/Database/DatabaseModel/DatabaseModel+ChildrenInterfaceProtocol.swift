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
        childrenInterface.add(child, on: _entityWrapper.entity)
    }

    func remove<Children: ChildrenInterfaceProtocol>(_ child: Children.ChildModel, in childrenKeyPath: KeyPath<Self, Children>)
    throws
    where Children.Entity == Entity {
        let childrenInterface = self[keyPath: childrenKeyPath]
        childrenInterface.remove(child, on: _entityWrapper.entity)
    }
}

public extension DatabaseModel where Entity: FetchableEntity {

    /// Publisher for the given relationship
    func publisher<Error, F: FieldPublisher & ChildrenInterfaceProtocol, Criteria>
    (for keyPath: KeyPath<Self, F>, sortedBy sort: Sort<F.ChildModel.Entity, Criteria>)
    -> AnyPublisher<F.Output, Error>
    where Error == F.OutputError, F.Entity == Entity, F.Output == [F.ChildModel] {
        self[keyPath: keyPath].publisher(for: _entityWrapper.entity, sortedBy: sort)
    }
}
