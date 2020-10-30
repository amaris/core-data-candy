//
// Copyright © 2018-present Amaris Software.
//

import CoreData

/// Can be fetched from the CoreData context. Add simple to use fetch functions on a CoreData entity or `DatabaseModel`.
public protocol Fetchable {}

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
        sorts: [Sort<Self>])
    throws -> [Self] {

        let request = fetch
        if let predicate = predicate {
            request.predicate = predicate
        }
        if let limit = limit {
            request.fetchLimit = limit
        }
        if !sorts.isEmpty {
            request.sortDescriptors = sorts.map { $0.descriptor }
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

    // MARK: No predicate

    /// Feth the entity in the context
    /// - Parameters:
    ///   - target: Retrieve, all values, the first one, the first nth ones...
    ///   - predicate: The comparison expression to use
    ///   - sorts: The sorts to apply to the returned data, in the order they are specified.
    ///   - context: The context where to fetch. Can be ignored if `Fetchable.context` is set with a non-nil value.
    /// - Throws: If the context fails to use the fetch request
    /// - Returns: The result of the fetch, depending on the given target
    ///
    /// For a given `People` model or CoreData managed object, here are some examples
    /// ```
    /// // fetch all the People older than 10
    /// // type: [People]
    /// People.fetch(.all(), where: \.age > 10, in: context)
    ///
    /// // fetch the first person with the name "Winnie"
    /// // type: People?
    /// People.fetch(.first(), where: \.name == "Winnie", in: context)
    ///
    /// // fetch all the People older than 10, sorted by their name
    /// // type: [People]
    /// People.fetch(.all(), where: \.age > 10,
    ///              sortedBy: .ascending(\.name),
    ///              in: context)
    ///
    /// // fetch all the People
    /// // type: [People]
    /// People.fetch(.all(), in: context)
    /// ```
    static func fetch<Output: FetchResult>(
        _ target: FetchTarget<Self, Output>,
        sortedBy sorts: Sort<Self>...,
        in context: NSManagedObjectContext? = context)
    throws -> Output
    where Output.Fetched == Self {

        let results = try fetch(predicate: nil, in: context, limit: target.limit, sorts: sorts)
        return Output(results: results)
    }

    // MARK: ComparisonPredicate

    /// Feth the entity in the context
    /// - Parameters:
    ///   - target: Retrieve, all values, the first one, the first nth ones...
    ///   - predicate: The comparison expression to use
    ///   - sorts: The sorts to apply to the returned data, in the order they are specified.
    ///   - context: The context where to fetch. Can be ignored if `Fetchable.context` is set with a non-nil value.
    /// - Throws: If the context fails to use the fetch request
    /// - Returns: The result of the fetch, depending on the given target
    ///
    /// For a given `People` model or CoreData managed object, here are some examples
    /// ```
    /// // fetch all the People older than 10
    /// // type: [People]
    /// People.fetch(.all(), where: \.age > 10, in: context)
    ///
    /// // fetch the first person with the name "Winnie"
    /// // type: People?
    /// People.fetch(.first(), where: \.name == "Winnie", in: context)
    ///
    /// // fetch all the People older than 10, sorted by their name
    /// // type: [People]
    /// People.fetch(.all(), where: \.age > 10,
    ///              sortedBy: .ascending(\.name),
    ///              in: context)
    ///
    /// // fetch all the People
    /// // type: [People]
    /// People.fetch(.all(), in: context)
    /// ```
    static func fetch<V: DatabaseFieldValue, Output: FetchResult>(
        _ target: FetchTarget<Self, Output>,
        where predicate: ComparisonPredicate<Self, V>,
        sortedBy sorts: Sort<Self>...,
        in context: NSManagedObjectContext? = context)
    throws -> Output
    where Output.Fetched == Self {

        let results = try fetch(predicate: predicate.nsValue, in: context, limit: target.limit, sorts: sorts)
        return Output(results: results)
    }

    // MARK: OperatorPredicate

    /// Feth the entity in the context
    /// - Parameters:
    ///   - target: Specify to retrieve all values, the first one, the first nth ones...
    ///   - keyPath: The property to use in the expression
    ///   - predOperator: An operator to apply to the property
    ///   - sorts: The sorts to apply to the returned data, in the order they are specified.
    ///   - context: The context where to fetch. Can be ignored if `Fetchable.context` is set with a non-nil value.
    /// - Throws: If the context fails to use the fetch request
    /// - Returns: The result of the fetch, depending on the given target
    ///
    /// For a given `People` model or CoreData managed object, here are some examples
    /// ```
    /// // fetch all the People whose name start with "Jo"
    /// // type: [People]
    /// People.fetch(.all(), where: \.name, .hasPrefix("Jo"), in: context)
    ///
    /// // fetch all the People whose name start with "Jo", sorted by their age
    /// // type: [People]
    /// People.fetch(.all(), where: \.name, .hasPrefix("Jo"),
    ///              sortedBy: .descending(\.age),
    ///              in: context)
    ///
    /// // fetch all the People older than 10 and younger than 30
    /// // type: [People]
    /// People.fetch(.all(), where: \.age, .isIn(10..<30),
    ///              in: context)
    ///
    /// // fetch the first 5 persons who have "Cooking" and "Surfing" as a hobby
    /// // type: [People]
    /// People.fetch(.first(nth: 5), where: \.hobby, .isIn("Cooking", "Surfing"),
    ///               in: context)
    ///
    /// // fetch the first person whose surname contains "Wood"
    /// // type: People?
    /// People.fetch(.first(nth: 5), where: \.surname, .contains("Wood"),
    ///               in: context)
    /// ```
    static func fetch<LeftOperand: DatabaseFieldValue, Output: FetchResult>(
        _ target: FetchTarget<Self, Output>,
        where keyPath: KeyPath<Self, LeftOperand>,
        _ predOperator: OperatorPredicate<LeftOperand>,
        sortedBy sorts: Sort<Self>...,
        in context: NSManagedObjectContext? = context)
    throws -> Output
    where Output.Fetched == Self {

        let results = try fetch(predicate: predOperator.predicate(for: keyPath), in: context, limit: target.limit, sorts: sorts)
        return Output(results: results)
    }

    // MARK: OperatorPredicate optional left operand

    /// Feth the entity in the context
    /// - Parameters:
    ///   - target: Specify to retrieve all values, the first one, the first nth ones...
    ///   - keyPath: The property to use in the expression
    ///   - predOperator: An operator to apply to the property
    ///   - sorts: The sorts to apply to the returned data, in the order they are specified.
    ///   - context: The context where to fetch. Can be ignored if `Fetchable.context` is set with a non-nil value.
    /// - Throws: If the context fails to use the fetch request
    /// - Returns: The result of the fetch, depending on the given target
    ///
    /// For a given `People` model or CoreData managed object, here are some examples
    /// ```
    /// // fetch all the People whose name start with "Jo"
    /// // type: [People]
    /// People.fetch(.all(), where: \.name, .hasPrefix("Jo"), in: context)
    ///
    /// // fetch all the People whose name start with "Jo", sorted by their age
    /// // type: [People]
    /// People.fetch(.all(), where: \.name, .hasPrefix("Jo"),
    ///              sortedBy: .descending(\.age),
    ///              in: context)
    ///
    /// // fetch all the People older than 10 and younger than 30
    /// // type: [People]
    /// People.fetch(.all(), where: \.age, .isIn(10..<30),
    ///              in: context)
    ///
    /// // fetch the first 5 persons who have "Cooking" and "Surfing" as a hobby
    /// // type: [People]
    /// People.fetch(.first(nth: 5), where: \.hobby, .isIn("Cooking", "Surfing"),
    ///               in: context)
    ///
    /// // fetch the first person whose surname contains "Wood"
    /// // type: People?
    /// People.fetch(.first(nth: 5), where: \.surname, .contains("Wood"),
    ///               in: context)
    /// ```
    static func fetch<LeftOperand: DatabaseFieldValue, Output: FetchResult>(
        _ target: FetchTarget<Self, Output>,
        where keyPath: KeyPath<Self, LeftOperand?>,
        _ predOperator: OperatorPredicate<LeftOperand>,
        sortedBy sorts: Sort<Self>...,
        in context: NSManagedObjectContext? = context)
    throws -> Output
    where Output.Fetched == Self {

        let results = try fetch(predicate: predOperator.predicate(for: keyPath), in: context, limit: target.limit, sorts: sorts)
        return Output(results: results)
    }
}

// MARK: - DatabaseModel Fetchable

public extension DatabaseModel where Entity: FetchableEntity {

    // MARK: No predicate

    /// Feth the model entity in the context
    /// - Parameters:
    ///   - target: Retrieve, all values, the first one, the first nth ones...
    ///   - predicate: The comparison expression to use
    ///   - sorts: The sorts to apply to the returned data, in the order they are specified.
    ///   - context: The context where to fetch. Can be ignored if `Fetchable.context` is set with a non-nil value.
    /// - Throws: If the context fails to use the fetch request
    /// - Returns: The result of the fetch, depending on the given target
    ///
    /// For a given `People` model or CoreData managed object, here are some examples
    /// ```
    /// // fetch all the People older than 10
    /// // type: [People]
    /// People.fetch(.all(), where: \.age > 10, in: context)
    ///
    /// // fetch the first person with the name "Winnie"
    /// // type: People?
    /// People.fetch(.first(), where: \.name == "Winnie", in: context)
    ///
    /// /// fetch all the People older than 10, sorted by their name
    /// // type: [People]
    /// People.fetch(.all(), where: \.age > 10,
    ///              sortedBy: .ascending(\.name),
    ///              in: context)
    ///
    /// // fetch all the People
    /// // type: [People]
    /// People.fetch(.all(), in: context)
    /// ```
    static func fetch<Output: FetchResult>(
        _ target: FetchTarget<Self, Output>,
        sortedBy sorts: Sort<Entity>...,
        in context: NSManagedObjectContext? = context)
    throws -> Output
    where Output.Fetched == Self {

        let results = try Entity.fetch(predicate: nil, in: context, limit: target.limit, sorts: sorts).map(Self.init)
        return Output(results: results)
    }

    // MARK: ComparisonPredicate

    /// Feth the model entity in the context
    /// - Parameters:
    ///   - target: Retrieve, all values, the first one, the first nth ones...
    ///   - predicate: The comparison expression to use
    ///   - sorts: The sorts to apply to the returned data, in the order they are specified.
    ///   - context: The context where to fetch. Can be ignored if `Fetchable.context` is set with a non-nil value.
    /// - Throws: If the context fails to use the fetch request. Can be ignored if `Fetchable.context` is set with a non-nil value.
    /// - Returns: The result of the fetch, depending on the given target
    ///
    /// For a given `People` model or CoreData managed object, here are some examples
    /// ```
    /// // fetch all the People older than 10
    /// // type: [People]
    /// People.fetch(.all(), where: \.age > 10, in: context)
    ///
    /// // fetch the first person with the name "Winnie"
    /// // type: People?
    /// People.fetch(.first(), where: \.name == "Winnie", in: context)
    ///
    /// /// fetch all the People older than 10, sorted by their name
    /// // type: [People]
    /// People.fetch(.all(), where: \.age > 10,
    ///              sortedBy: .ascending(\.name),
    ///              in: context)
    ///
    /// // fetch all the People
    /// // type: [People]
    /// People.fetch(.all(), in: context)
    /// ```
    static func fetch<V: DatabaseFieldValue, Output: FetchResult>(
        _ target: FetchTarget<Self, Output>,
        where predicate: ComparisonPredicate<Entity, V>,
        sortedBy sorts: Sort<Entity>...,
        in context: NSManagedObjectContext? = context)
    throws -> Output
    where Output.Fetched == Self {

        let results = try Entity.fetch(predicate: predicate.nsValue, in: context, limit: target.limit, sorts: sorts).map(Self.init)
        return Output(results: results)
    }

    // MARK: OperatorPredicate

    /// Feth the model entity in the context
    /// - Parameters:
    ///   - target: Specify to retrieve all values, the first one, the first nth ones...
    ///   - keyPath: The property to use in the expression
    ///   - predOperator: An operator to apply to the property
    ///   - sorts: The sorts to apply to the returned data, in the order they are specified.
    ///   - context: The context where to fetch. Can be ignored if `Fetchable.context` is set with a non-nil value.
    /// - Throws: If the context fails to use the fetch request
    /// - Returns: The result of the fetch, depending on the given target
    ///
    /// For a given `People` model or CoreData managed object, here are some examples
    /// ```
    /// // fetch all the People whose name start with "Jo"
    /// // type: [People]
    /// People.fetch(.all(), where: \.name, .hasPrefix("Jo"), in: context)
    ///
    /// // fetch all the People whose name start with "Jo", sorted by their age
    /// // type: [People]
    /// People.fetch(.all(), where: \.name, .hasPrefix("Jo"),
    ///              sortedBy: .descending(\.age),
    ///              in: context)
    ///
    /// // fetch all the People older than 10 and younger than 30
    /// // type: [People]
    /// People.fetch(.all(), where: \.age, .isIn(10..<30),
    ///              in: context)
    ///
    /// // fetch the first 5 persons who have "Cooking" and "Surfing" as a hobby
    /// // type: [People]
    /// People.fetch(.first(nth: 5), where: \.hobby, .isIn("Cooking", "Surfing"),
    ///               in: context)
    ///
    /// // fetch the first person whose surname contains "Wood"
    /// // type: People?
    /// People.fetch(.first(nth: 5), where: \.surname, .contains("Wood"),
    ///               in: context)
    /// ```
    static func fetch<LeftOperand: DatabaseFieldValue, Output: FetchResult>(
        _ target: FetchTarget<Self, Output>,
        where keyPath: KeyPath<Entity, LeftOperand>,
        _ predOperator: OperatorPredicate<LeftOperand>,
        sortedBy sorts: Sort<Entity>...,
        in context: NSManagedObjectContext? = context)
    throws -> Output
    where Output.Fetched == Self {

        let results = try Entity.fetch(predicate: predOperator.predicate(for: keyPath), in: context, limit: target.limit, sorts: sorts).map(Self.init)
        return Output(results: results)
    }

    // MARK: OperatorPredicate optional left operand

    /// Feth the model entity in the context
    /// - Parameters:
    ///   - target: Specify to retrieve all values, the first one, the first nth ones...
    ///   - keyPath: The property to use in the expression
    ///   - predOperator: An operator to apply to the property
    ///   - sorts: The sorts to apply to the returned data, in the order they are specified.
    ///   - context: The context where to fetch. Can be ignored if `Fetchable.context` is set with a non-nil value.
    /// - Throws: If the context fails to use the fetch request
    /// - Returns: The result of the fetch, depending on the given target
    ///
    /// For a given `People` model or CoreData managed object, here are some examples
    /// ```
    /// // fetch all the People whose name start with "Jo"
    /// // type: [People]
    /// People.fetch(.all(), where: \.name, .hasPrefix("Jo"), in: context)
    ///
    /// // fetch all the People whose name start with "Jo", sorted by their age
    /// // type: [People]
    /// People.fetch(.all(), where: \.name, .hasPrefix("Jo"),
    ///              sortedBy: .descending(\.age),
    ///              in: context)
    ///
    /// // fetch all the People older than 10 and younger than 30
    /// // type: [People]
    /// People.fetch(.all(), where: \.age, .isIn(10..<30),
    ///              in: context)
    ///
    /// // fetch the first 5 persons who have "Cooking" and "Surfing" as a hobby
    /// // type: [People]
    /// People.fetch(.first(nth: 5), where: \.hobby, .isIn("Cooking", "Surfing"),
    ///               in: context)
    ///
    /// // fetch the first person whose surname contains "Wood"
    /// // type: People?
    /// People.fetch(.first(nth: 5), where: \.surname, .contains("Wood"),
    ///               in: context)
    /// ```
    static func fetch<LeftOperand: DatabaseFieldValue, Output: FetchResult>(
        _ target: FetchTarget<Self, Output>,
        where keyPath: KeyPath<Entity, LeftOperand?>,
        _ predOperator: OperatorPredicate<LeftOperand>,
        sortedBy sorts: Sort<Entity>...,
        in context: NSManagedObjectContext? = context)
    throws -> Output
    where Output.Fetched == Self {

        let results = try Entity.fetch(predicate: predOperator.predicate(for: keyPath), in: context, limit: target.limit, sorts: sorts).map(Self.init)
        return Output(results: results)
    }
}
