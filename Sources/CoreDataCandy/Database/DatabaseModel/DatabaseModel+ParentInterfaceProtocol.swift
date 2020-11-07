//
// Copyright © 2018-present Amaris Software.
//

import CoreData

public extension DatabaseModel {

    func current<Value, P: ParentInterfaceProtocol>(_ parentKeyPath: KeyPath<Self, P>, _ valueKeyPath: KeyPath<P.ParentModel.Entity, Value>)
    -> Value?
    where P.ParentModel.Entity: NSManagedObject, P.Entity == Entity {
        self[keyPath: parentKeyPath].current(for: valueKeyPath, on: entity)
    }

    func current<Value, P: ParentInterfaceProtocol>(_ parentKeyPath: KeyPath<Self, P>, _ valueKeyPath: KeyPath<P.ParentModel.Entity, Value?>)
    -> Value?
    where P.ParentModel.Entity: NSManagedObject, P.Entity == Entity {
        self[keyPath: parentKeyPath].current(valueKeyPath, on: entity)
    }
}
