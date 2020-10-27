//
// Copyright © 2018-present Amaris Software.
//

public extension DatabaseModel {

    func insert<ChildModel: DatabaseModel>(_ child: ChildModel, at index: Int, in childrenKeyPath: KeyPath<Self, OrderedChildren<ChildModel>>) throws {
        let childrenInterface = self[keyPath: childrenKeyPath]
        childrenInterface.insert(child, at: index, on: entity)
        try saveEntityContext()
    }

    func remove<ChildModel: DatabaseModel>(at index: Int, in childrenKeyPath: KeyPath<Self, OrderedChildren<ChildModel>>) throws {
        let childrenInterface = self[keyPath: childrenKeyPath]
        childrenInterface.remove(at: index, on: entity)
        try saveEntityContext()
    }
}
