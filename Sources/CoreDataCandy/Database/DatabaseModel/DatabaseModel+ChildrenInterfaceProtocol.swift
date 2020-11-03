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
}
