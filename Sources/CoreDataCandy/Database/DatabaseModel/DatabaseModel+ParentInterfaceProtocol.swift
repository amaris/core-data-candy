//
// Copyright © 2018-present Amaris Software.
//

import CoreData

public extension DatabaseModel {

    /// Current value for the given parent's field
    func current<Value, P: ParentInterfaceProtocol>(_ parentKeyPath: KeyPath<Self, P>, _ valueKeyPath: KeyPath<P.ParentModel.Entity, Value>)
    -> Value?
    where P.ParentModel.Entity: NSManagedObject, P.Entity == Entity {
        self[keyPath: parentKeyPath].current(valueKeyPath, on: _entityWrapper.entity)
    }

    /// Current value for the given parent's field
    func current<Value, P: ParentInterfaceProtocol>(_ parentKeyPath: KeyPath<Self, P>, _ valueKeyPath: KeyPath<P.ParentModel.Entity, Value?>)
    -> Value?
    where P.ParentModel.Entity: NSManagedObject, P.Entity == Entity {
        self[keyPath: parentKeyPath].current(valueKeyPath, on: _entityWrapper.entity)
    }
}
