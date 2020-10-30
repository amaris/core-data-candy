//
// Copyright © 2018-present Amaris Software.
//

import Foundation

/// Holds the logic to access a children (one to many) relationship
public protocol ChildrenInterfaceProtocol {
    associatedtype Entity: DatabaseEntity
    associatedtype ChildModel: DatabaseModel

    func add(_ child: ChildModel, on entity: Entity)
    func remove(_ child: ChildModel, on entity: Entity)
}
