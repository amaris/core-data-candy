//
// Copyright © 2018-present Amaris Software.
//

import CoreData

/// Holds the logic to access a children (one to many) relationship
public protocol ChildrenInterfaceProtocol {
    associatedtype Entity: DatabaseEntity
    associatedtype ChildModel: DatabaseModel

    func add(_ child: ChildModel, on entity: Entity)
    func remove(_ child: ChildModel, on entity: Entity)
}

extension ChildrenInterfaceProtocol where ChildModel.Entity: NSManagedObject {

    func childModel(from entity: Any) -> ChildModel {
        guard let entity = entity as? ChildModel.Entity else {
            preconditionFailure("The children are not of type \(ChildModel.Entity.self)")
        }
        return ChildModel(entity: entity)
    }
}
