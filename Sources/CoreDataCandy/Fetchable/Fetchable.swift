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

    static var fetch: NSFetchRequest<Self> {
        NSFetchRequest<Self>(entityName: String(describing: Self.self))
    }
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

// MARK: - Fetchable Entity

extension FetchableEntity {

    static func fetch(
        predicate: NSPredicate?,
        in context: NSManagedObjectContext?,
        limit: Int? = nil,
        sorts: [SortDescriptor<Self>])
    throws -> [Self] {

        let request = fetch
        if let predicate = predicate {
            request.predicate = predicate
        }
        if let limit = limit {
            request.fetchLimit = limit
        }
        if !sorts.isEmpty {
            request.sortDescriptors = sorts.map(\.descriptor)
        }
        guard let context = context else {
            assertionFailure("No context was provided to fetch the request. Consider passing it as a parameter or changing the default 'nil' value of 'Fetchable.context'")
            return []
        }
        let results = try context.fetch(request)
        return results
    }
}

public extension FetchableEntity {

    /// Feth the model entity in the context
    /// - Parameters:
    ///   - target: Retrieve, all values, the first one, the first nth ones...
    ///   - predicate: The comparison expression to use
    ///   - sorts: The sorts to apply to the returned data, in the order they are specified.
    ///   - context: The context where to fetch. Can be ignored if `Fetchable.context` is set with a non-nil value.
    /// - Throws: If the context fails to use the fetch request
    /// - Returns: The result of the fetch request, depending on the given target
    ///
    /// For a given `People` model or CoreData managed object, here are some examples
    /// ```
    /// // fetch all the People older than 10
    /// // output: [People]
    /// People.fetch(.all(), .where(\.age > 10), in: context)
    ///
    /// // fetch the first person with the name "Mickey" or "Donald"
    /// // output: People?
    /// People.fetch(.first(), .where(\.name, isIn: "Mickey", "Donald"),
    ///              in: context)
    ///
    /// /// fetch all the People older than 10, sorted by their name
    /// // type: [People]
    /// People.fetch(.all(), .where(\.age > 10),
    ///              sortedBy: .ascending(\.name),
    ///              in: context)
    ///
    /// // fetch all the People
    /// // output: [People]
    /// People.fetch(.all(), in: context)
    /// ```
    static func fetch<Value: DatabaseFieldValue, RightOperand, Output: FetchResult>(
        _ target: FetchTarget<Self, Output>,
        _ predicate: Predicate<Self, Value, RightOperand>? = nil,
        sortedBy sorts: SortDescriptor<Self>...,
        in context: NSManagedObjectContext? = context)
    throws -> Output
    where Output.Fetched == Self {
        let results = try fetch(predicate: predicate?.ns, in: context, limit: target.limit, sorts: sorts)
        return Output(results: results)
    }
}

public extension DatabaseModel where Entity: FetchableEntity {

    /// Feth the model entity in the context
    /// - Parameters:
    ///   - target: Retrieve, all values, the first one, the first nth ones...
    ///   - predicate: The comparison expression to use
    ///   - sorts: The sorts to apply to the returned data, in the order they are specified.
    ///   - context: The context where to fetch. Can be ignored if `Fetchable.context` is set with a non-nil value.
    /// - Throws: If the context fails to use the fetch request
    /// - Returns: The result of the fetch request, depending on the given target
    ///
    /// For a given `People` model or CoreData managed object, here are some examples
    /// ```
    /// // fetch all the People older than 10
    /// // output: [People]
    /// People.fetch(.all(), .where(\.age > 10), in: context)
    ///
    /// // fetch the first person with the name "Mickey" or "Donald"
    /// // output: People?
    /// People.fetch(.first(), .where(\.name, isIn: "Mickey", "Donald"),
    ///              in: context)
    ///
    /// /// fetch all the People older than 10, sorted by their name
    /// // type: [People]
    /// People.fetch(.all(), .where(\.age > 10),
    ///              sortedBy: .ascending(\.name),
    ///              in: context)
    ///
    /// // fetch all the People
    /// // output: [People]
    /// People.fetch(.all(), in: context)
    /// ```
    static func fetch<Value: DatabaseFieldValue, RightOperand, Output: FetchResult>(
        _ target: FetchTarget<Self, Output>,
        _ predicate: Predicate<Entity, Value, RightOperand>? = nil,
        sortedBy sorts: SortDescriptor<Entity>...,
        in context: NSManagedObjectContext? = context)
    throws -> Output
    where Output.Fetched == Self {
        let results = try Entity.fetch(predicate: predicate?.ns, in: context, limit: target.limit, sorts: sorts).map(Self.init)
        return Output(results: results)
    }
}
