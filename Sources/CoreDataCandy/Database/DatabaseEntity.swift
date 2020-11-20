//
// CoreDataCandy
// Copyright © 2018-present Amaris Software.
// MIT license, see LICENSE file for details

import CoreData

/// A CoreData entity to be interface with a `DatabaseModel`
public protocol DatabaseEntity: NSManagedObject, Fetchable {

    var managedObjectContext: NSManagedObjectContext? { get }

    init(context moc: NSManagedObjectContext)

    /// The associated Database model name for fetching to be used when throwing a detailed error.
    /// A default implementation is provided, which is useful when the entity is name accordingly
    /// to its `DatabaseModel` counterpart with an 'Entity' suffix (e.g. 'PlayerEntity')
    static var modelName: String { get }
}

public extension DatabaseEntity {

    static var modelName: String {
        // Default implementation of the model name
        let entityIdentifier = "Entity"
        var className = String(describing: self)

        if className.hasSuffix(entityIdentifier) {
            className.removeLast(entityIdentifier.count)
        }
        return className
    }
}
