//
// Copyright © 2018-present Amaris Software.
//

import CoreData

/// Can be fetched from the CoreData context. Add simple to use fetch functions on a CoreData entity or `DatabaseModel`.
public protocol Fetchable {

    static var context: NSManagedObjectContext? { get }
}

public extension Fetchable {

    static var context: NSManagedObjectContext? { nil }
}

/// A CoreData entity with augmented fetch requests
public protocol FetchableEntity: NSManagedObject, DatabaseEntity, Fetchable {

    /// The associated Database model name for fetching when throwing a detailled error
    static var modelName: String { get }
}

public extension FetchableEntity where Self: NSManagedObject {

    static var fetch: NSFetchRequest<Self> { NSFetchRequest<Self>(entityName: String(describing: Self.self)) }
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
