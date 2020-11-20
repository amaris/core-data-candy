//
// CoreDataCandy
// Copyright © 2018-present Amaris Software.
// MIT license, see LICENSE file for details

import Combine
import CoreData

public extension DatabaseModel {

    /// Current value of the one-to-any relationship
    func current<Children: ChildrenInterfaceProtocol>(_ keyPath: KeyPath<Self, Children>)
    -> [Children.ChildModel]
    where Children.Entity == Entity {
        self[keyPath: keyPath].currentValue(on: entity)
    }

    /// Add a child to the one-ton-many relationship
    func add<Children: ChildrenInterfaceProtocol>(_ child: Children.ChildModel, to childrenKeyPath: KeyPath<Self, Children>)
    where Children.Entity == Entity {
        let childrenInterface = self[keyPath: childrenKeyPath]
        childrenInterface.add(child, on: entity)
    }

    /// Remove a child from the one-ton-many relationship
    func remove<Children: ChildrenInterfaceProtocol>(_ child: Children.ChildModel, to childrenKeyPath: KeyPath<Self, Children>)
    where Children.Entity == Entity {
        let childrenInterface = self[keyPath: childrenKeyPath]
        childrenInterface.remove(child, on: entity)
    }
}

public extension DatabaseModel where Entity: DatabaseEntity {

    /// Publisher for the given relationship
    /// - Parameters:
    ///   - keyPath: The children to observe
    ///   - sorts: Sorts to be applied to the emitted array
    /// - Returns: An array of the children
    ///
    /// ### Examples
    ///  - `publisher(for: \.children, sortedBy: .ascending(\.property))`
    ///  - `publisher(for: \.children, sortedBy: .descending(\.date), .ascending(\.name))`
    ///
    func publisher<F: FieldPublisher & ChildrenInterfaceProtocol>(
        for keyPath: KeyPath<Self, F>,
        sortedBy sorts: Sort<F.ChildModel.Entity>...)
    -> AnyPublisher<F.Output, Never>
    where F.Entity == Entity, F.Output == [F.ChildModel] {
        self[keyPath: keyPath].publisher(for: entity, sortedBy: sorts)
    }
}
