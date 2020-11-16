//
// Copyright © 2018-present Amaris Software.
//

import CoreData

/// Can be fetched from the Core Data context. Adds simple to use fetch functions on a Core Data entity or `DatabaseModel`.
public protocol Fetchable {

    /// If a non `nil` value is provided, all fetch requests will use this context
    /// when no other context is provided.
    /// This is an opportunity to pass the application main `viewContext` to not
    /// have to pass it as a parameter each time a fetch request is executed.
    static var context: NSManagedObjectContext? { get }
}

public extension Fetchable {

    static var context: NSManagedObjectContext? { nil }
}

/// A CoreData entity with augmented fetch requests
public protocol FetchableEntity: NSManagedObject, DatabaseEntity, Fetchable {

    /// The associated Database model name for fetching to be used when throwing a detailed error.
    /// A default implementation is provided, which is useful when the entity is name accordingly
    /// to its `DatabaseModel` counterpart with an 'Entity' suffix (e.g. 'PlayerEntity')
    static var modelName: String { get }
}

public extension FetchableEntity where Self: NSManagedObject {

    /// `NSFetchRequest` to fetch the entity
    static func newFetchRequest() -> NSFetchRequest<Self> { NSFetchRequest<Self>(entityName: String(describing: Self.self)) }
}

public extension FetchableEntity {

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
