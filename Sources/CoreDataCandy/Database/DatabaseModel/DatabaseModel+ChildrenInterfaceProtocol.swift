//
// CoreDataCandy
// Copyright © 2018-present Amaris Software.
// MIT license, see LICENSE file for details

import Combine
import CoreData

public extension DatabaseModel {

    func current<Children: ChildrenInterfaceProtocol>(_ keyPath: KeyPath<Self, Children>)
    -> [Children.ChildModel]
    where Children.Entity == Entity {
        self[keyPath: keyPath].currentValue(on: entity)
    }

    func add<Children: ChildrenInterfaceProtocol>(_ child: Children.ChildModel, to childrenKeyPath: KeyPath<Self, Children>)
    where Children.Entity == Entity {
        let childrenInterface = self[keyPath: childrenKeyPath]
        childrenInterface.add(child, on: entity)
    }

    func remove<Children: ChildrenInterfaceProtocol>(_ child: Children.ChildModel, to childrenKeyPath: KeyPath<Self, Children>)
    where Children.Entity == Entity {
        let childrenInterface = self[keyPath: childrenKeyPath]
        childrenInterface.remove(child, on: entity)
    }

    // MARK: Ordered

    func insert<ChildModel: DatabaseModel>(_ child: ChildModel, at index: Int, in childrenKeyPath: KeyPath<Self, OrderedChildren<ChildModel>>) throws {
        let childrenInterface = self[keyPath: childrenKeyPath]
        childrenInterface.insert(child, at: index, on: entity)
    }

    func remove<ChildModel: DatabaseModel>(at index: Int, in childrenKeyPath: KeyPath<Self, OrderedChildren<ChildModel>>) throws {
        let childrenInterface = self[keyPath: childrenKeyPath]
        childrenInterface.remove(at: index, on: entity)
    }

    // MARK: Publisher

    func publisher<F: FieldPublisher & ChildrenInterfaceProtocol>(
        for keyPath: KeyPath<Self, F>,
        sortedBy sorts: Sort<F.ChildModel.Entity>...)
    -> AnyPublisher<F.Output, Never>
    where F.Entity == Entity, F.Output == [F.ChildModel] {
        self[keyPath: keyPath].publisher(for: entity, sortedBy: sorts)
    }
}

public extension Collection where Element: DatabaseModel {

    /// Map the current value of the field
    func flatMapCurrent<C: ChildrenInterfaceProtocol>(_ keyPath: KeyPath<Element, C>) -> [C.ChildModel] where Element.Entity == C.Entity {
        flatMap { $0.current(keyPath) }
    }
}
