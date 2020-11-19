//
// Copyright © 2018-present Amaris Software.
//

import CoreData

/// Can be fetched from the Core Data context. Provide a way to specify the context where to fetch in a single place.
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

public extension DatabaseEntity {

    /// `NSFetchRequest` to fetch the entity
    static func newFetchRequest() -> NSFetchRequest<Self> { .init(entityName: String(describing: Self.self)) }
}
