//
// Copyright © 2018-present Amaris Software.
//

import Foundation
import CoreData

/// A step in the fetch request building process
public protocol FetchRequestStep {}

// Fetch → Target → Predicate → Sort
public enum FetchStep: FetchRequestStep {}
public enum TargetStep: FetchRequestStep {}
public enum PredicateStep: FetchRequestStep {}
public enum SortStep: FetchRequestStep {}

/// `RequestBuilder` with no target
public struct PreRequestBuilder<Entity: FetchableEntity, Step: FetchRequestStep, Fetched: Fetchable> {
    var request: NSFetchRequest<Entity>
}

/// Passed from one `RequestBuilder` to another to incrementally build a `NSFetchRequest`
public struct RequestBuilder<Entity: FetchableEntity, Step: FetchRequestStep, Output: FetchResult> {

    public typealias FetchRequest = NSFetchRequest<Entity>

    public let request: FetchRequest

    init(request: FetchRequest) {
        self.request = request
    }

    public func setting<Value>(_ keyPath: ReferenceWritableKeyPath<FetchRequest, Value>, to value: Value) -> Self {
        request[keyPath: keyPath] = value
        return self
    }
}

// MARK: - Output

extension RequestBuilder where Output.Fetched == Entity {

    public func fetch(in context: NSManagedObjectContext? = Entity.context) throws -> Output {
        guard let context = context else {
            assertionFailure("No context was provided to fetch the request. Consider passing it as a parameter or changing the default 'nil' value of 'Fetchable.context'")
            return Output(results: [])
        }
        return Output(results: try context.fetch(request))
    }
}

public extension FetchableEntity {

    static func request() -> PreRequestBuilder<Self, FetchStep, Self> {
        let request = Self.fetch
        return PreRequestBuilder<Self, FetchStep, Self>(request: request)
    }
}

extension RequestBuilder where Output.Fetched: DatabaseModel, Output.Fetched.Entity == Entity {

    public func fetch(in context: NSManagedObjectContext? = Entity.context) throws -> Output {
        guard let context = context else {
            assertionFailure("No context was provided to fetch the request. Consider passing it as a parameter or changing the default 'nil' value of 'Fetchable.context'")
            return Output(results: [])
        }

        return Output(results: try context.fetch(request).map(Output.Fetched.init))
    }
}

public extension DatabaseModel where Entity: FetchableEntity {

    static func request() -> PreRequestBuilder<Entity, FetchStep, Self> {
        let request = Entity.fetch
        return PreRequestBuilder<Entity, FetchStep, Self>(request: request)
    }
}

// MARK: - Steps

// MARK: Fetch step

public extension PreRequestBuilder where Step == FetchStep {

    func assign<Value>(_ value: Value?, ifNotNilTo keyPath: ReferenceWritableKeyPath<NSFetchRequest<Entity>, Value>) {
        if let value = value {
            request[keyPath: keyPath] = value
        }
    }

    /// Return after a first element is fetched
    func first() -> RequestBuilder<Entity, TargetStep, Fetched?> {
        RequestBuilder<Entity, TargetStep, Fetched?>(request: request)
    }

    /// Return after the first nth elements are fetched
    /// - Parameters:
    ///   - limit: How much elements should be fetched
    ///   - offset: Ignore the first elements found in the offset range
    func first(nth limit: Int, after offset: Int? = nil) -> RequestBuilder<Entity, TargetStep, [Fetched]> {
        request.fetchLimit = limit
        assign(offset, ifNotNilTo: \.fetchOffset)
        return RequestBuilder<Entity, TargetStep, [Fetched]>(request: request)
    }

    /// Return after the all the elements are fetched
    /// - Parameters:
    ///   - offset: Ignore the first elements found in the offset range
    func all(after offset: Int? = nil) -> RequestBuilder<Entity, TargetStep, [Fetched]> {
        assign(offset, ifNotNilTo: \.fetchOffset)
        return RequestBuilder<Entity, TargetStep, [Fetched]>(request: request)
    }
}

// MARK: Target step

public extension RequestBuilder where Step == TargetStep {

    func `where`<Value: DatabaseFieldValue, TestValue>(_ predicate: Predicate<Entity, Value, TestValue>)
    -> RequestBuilder<Entity, PredicateStep, Output> {
        request.predicate = predicate.nsValue
        return .init(request: request)
    }

    func `where`<Value: DatabaseFieldValue & Equatable, TestValue>(
        _ keyPath: KeyPath<Entity, Value>,
        _ predicateRightValue: PredicateRightValue<Entity, Value, TestValue>)
    -> RequestBuilder<Entity, PredicateStep, Output> {

        request.predicate = predicateRightValue.predicate(keyPath).nsValue
        return .init(request: request)
    }
}

// MARK: Predicate step

public extension RequestBuilder where Step == PredicateStep {

    func or<Value: DatabaseFieldValue, TestValue>(_ predicate: Predicate<Entity, Value, TestValue>) -> RequestBuilder<Entity, PredicateStep, Output> {

        guard let predicateFormat = request.predicate?.predicateFormat else { return .init(request: request) }

        let newPredicateFormat = "\(predicateFormat) OR \(predicate.nsValue.predicateFormat)"
        request.predicate = NSPredicate(format: newPredicateFormat)
        return self
    }

    func or<Value: DatabaseFieldValue & Equatable, TestValue>(
        _ keyPath: KeyPath<Entity, Value>,
        _ predicateRightValue: PredicateRightValue<Entity, Value, TestValue>)
    -> RequestBuilder<Entity, PredicateStep, Output> {

        guard let predicateFormat = request.predicate?.predicateFormat else { return .init(request: request) }

        let newPredicateFormat = "\(predicateFormat) OR \(predicateRightValue.predicate(keyPath).nsValue)"
        request.predicate = NSPredicate(format: newPredicateFormat)
        return self
    }

    func and<Value: DatabaseFieldValue, TestValue>(_ predicate: Predicate<Entity, Value, TestValue>) -> RequestBuilder<Entity, PredicateStep, Output> {

        guard let predicateFormat = request.predicate?.predicateFormat else { return .init(request: request) }

        let newPredicateFormat = "(\(predicateFormat)) AND \(predicate.nsValue.predicateFormat)"
        request.predicate = NSPredicate(format: newPredicateFormat)
        return self
    }

    func and<Value: DatabaseFieldValue & Equatable, TestValue>(
        _ keyPath: KeyPath<Entity, Value>,
        _ predicateRightValue: PredicateRightValue<Entity, Value, TestValue>)
    -> RequestBuilder<Entity, PredicateStep, Output> {

        guard let predicateFormat = request.predicate?.predicateFormat else { return .init(request: request) }

        let newPredicateFormat = "(\(predicateFormat)) AND \(predicateRightValue.predicate(keyPath).nsValue)"
        request.predicate = NSPredicate(format: newPredicateFormat)
        return self
    }
}

// MARK: Sort step

public extension RequestBuilder {

    enum SortDirection {
        case ascending, descending
    }
}

public extension RequestBuilder where Step == PredicateStep {

    func sorted<Value: DatabaseFieldValue & Comparable>(by direction: SortDirection, _ keyPath: KeyPath<Entity, Value>) -> RequestBuilder<Entity, SortStep, Output> {
        let descriptor = NSSortDescriptor(key: keyPath.label, ascending: direction == .ascending)
        request.sortDescriptors = [descriptor]
        return .init(request: request)
    }

    func sorted<Value: DatabaseFieldValue & Comparable>(by direction: SortDirection, _ keyPath: KeyPath<Entity, Value?>) -> RequestBuilder<Entity, SortStep, Output> {
        let descriptor = NSSortDescriptor(key: keyPath.label, ascending: direction == .ascending)
        request.sortDescriptors = [descriptor]
        return .init(request: request)
    }
}

public extension RequestBuilder where Step == SortStep {

    func then<Value: DatabaseFieldValue & Comparable>(by direction: SortDirection, _ keyPath: KeyPath<Entity, Value>) -> RequestBuilder<Entity, SortStep, Output> {
        let descriptor = NSSortDescriptor(key: keyPath.label, ascending: direction == .ascending)
        request.sortDescriptors = (request.sortDescriptors ?? []) + [descriptor]
        return self
    }

    func then<Value: DatabaseFieldValue & Comparable>(by direction: SortDirection, _ keyPath: KeyPath<Entity, Value?>) -> RequestBuilder<Entity, SortStep, Output> {
        let descriptor = NSSortDescriptor(key: keyPath.label, ascending: direction == .ascending)
        request.sortDescriptors = (request.sortDescriptors ?? []) + [descriptor]
        return self
    }
}
