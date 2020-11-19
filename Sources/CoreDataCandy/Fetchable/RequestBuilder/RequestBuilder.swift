//
// Copyright © 2018-present Amaris Software.
//

import Foundation
import CoreData

// MARK: - Steps definition

/// A step in the fetch request building process
public protocol FetchRequestStep {}

/// Identify a step where a sort step can be applied
public protocol SortableStep {}

/// Identify a step where a settings step can be applied
public protocol SettingsStep {}

// Creation → Target → Predicate → Sort
/// The request has been created
public enum CreationStep: FetchRequestStep {}
/// The request has a target
public enum TargetStep: FetchRequestStep, SortableStep, SettingsStep {}
/// The request has a predicate
public enum PredicateStep: FetchRequestStep, SortableStep, SettingsStep {}
/// The request has one or more sorts
public enum SortStep: FetchRequestStep, SettingsStep {}

// MARK: - Request builder

/// `RequestBuilder` with no target
public struct PreRequestBuilder<Entity: DatabaseEntity, Step: FetchRequestStep, Fetched: Fetchable> {
    var request: NSFetchRequest<Entity>
}

/// Passed from one `RequestBuilder` to another to incrementally build a `NSFetchRequest`
public struct RequestBuilder<Entity: DatabaseEntity, Step: FetchRequestStep, Output: FetchResult> {

    public typealias FetchRequest = NSFetchRequest<Entity>

    public let request: FetchRequest

    init(request: FetchRequest) {
        self.request = request
    }
}

// MARK: RequestBuilder + DatabaseEntity

extension RequestBuilder where Output.Fetched == Entity {

    /// Execute the fetch request in the context, using `Fetchable.context` if no context is provided
    public func fetch(in context: NSManagedObjectContext? = Entity.context) throws -> Output {
        guard let context = context else {
            assertionFailure("No context was provided to fetch the request. Consider passing it as a parameter or changing the default 'nil' value of 'Fetchable.context'")
            return Output(results: [])
        }
        return Output(results: try context.fetch(request))
    }
}

public extension DatabaseEntity {

    /// Starts the request building process with a new request
    static func request() -> PreRequestBuilder<Self, CreationStep, Self> {
        let request = Self.newFetchRequest()
        return PreRequestBuilder<Self, CreationStep, Self>(request: request)
    }
}

// MARK: RequestBuilder + DatabaseModel

extension RequestBuilder where Output.Fetched: DatabaseModel, Output.Fetched.Entity == Entity {

    /// Execute the fetch request in the context, using `Fetchable.context` if no context is provided
    public func fetch(in context: NSManagedObjectContext? = Entity.context) throws -> Output {
        guard let context = context else {
            assertionFailure("No context was provided to fetch the request. Consider passing it as a parameter or changing the default 'nil' value of 'Fetchable.context'")
            return Output(results: [])
        }

        return Output(results: try context.fetch(request).map(Output.Fetched.init))
    }
}

public extension DatabaseModel where Entity: DatabaseEntity {

    static func request() -> PreRequestBuilder<Entity, CreationStep, Self> {
        let request = Entity.newFetchRequest()
        return PreRequestBuilder<Entity, CreationStep, Self>(request: request)
    }
}
