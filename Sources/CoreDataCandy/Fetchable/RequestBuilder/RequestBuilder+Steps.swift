//
// Copyright © 2018-present Amaris Software.
//

import CoreData

// MARK: Settings

extension RequestBuilder where Step: SettingsStep {

    public func setting<Value>(_ keyPath: ReferenceWritableKeyPath<FetchRequest, Value>, to value: Value) -> Self {
        request[keyPath: keyPath] = value
        return self
    }
}

// MARK: Fetch

public extension PreRequestBuilder where Step == CreationStep {

    private func assign<Value>(_ value: Value?, ifNotNilTo keyPath: ReferenceWritableKeyPath<NSFetchRequest<Entity>, Value>) {
        if let value = value {
            request[keyPath: keyPath] = value
        }
    }

    /// Returns after a first element is fetched
    func first() -> RequestBuilder<Entity, TargetStep, Fetched?> {
        RequestBuilder<Entity, TargetStep, Fetched?>(request: request)
    }

    /// Returns after the first nth elements are fetched
    /// - Parameters:
    ///   - limit: How much elements should be fetched
    ///   - offset: Ignore the first elements found in the offset range
    func first(nth limit: Int, after offset: Int? = nil) -> RequestBuilder<Entity, TargetStep, [Fetched]> {
        request.fetchLimit = limit
        assign(offset, ifNotNilTo: \.fetchOffset)
        return RequestBuilder<Entity, TargetStep, [Fetched]>(request: request)
    }

    /// Returns after the all the elements are fetched
    /// - Parameters:
    ///   - offset: Ignore the first elements found in the offset range
    func all(after offset: Int? = nil) -> RequestBuilder<Entity, TargetStep, [Fetched]> {
        assign(offset, ifNotNilTo: \.fetchOffset)
        return RequestBuilder<Entity, TargetStep, [Fetched]>(request: request)
    }
}

// MARK: Target

public extension RequestBuilder where Step == TargetStep {

    /// Basic comparison predicate
    /// ### Examples
    ///  - `.where(\.keyPath == "Value")`
    ///  - `.where(\.keyPath >= 20)`
    func `where`<Value: DatabaseFieldValue, TestValue>(_ predicate: Predicate<Entity, Value, TestValue>)
    -> RequestBuilder<Entity, PredicateStep, Output> {
        request.predicate = predicate.nsValue
        return .init(request: request)
    }

    /// Advanced comparison predicate
    /// ### Examples
    /// - `.where(\.keyPath, .isIn(1...100))`
    /// - `.where(\.keyPath, .hasPrefix("Mon"))`
    func `where`<Value: DatabaseFieldValue & Equatable, TestValue>(
        _ keyPath: KeyPath<Entity, Value>,
        _ predicateRightValue: PredicateRightValue<Entity, Value, TestValue>)
    -> RequestBuilder<Entity, PredicateStep, Output> {

        request.predicate = predicateRightValue.predicate(keyPath).nsValue
        return .init(request: request)
    }
}

// MARK: Predicate

public extension RequestBuilder where Step == PredicateStep {

    /// Basic comparison predicate
    /// ### Examples
    ///  - `.or(\.keyPath == "Value")`
    ///  - `.or(\.keyPath >= 20)`
    func or<Value: DatabaseFieldValue, TestValue>(_ predicate: Predicate<Entity, Value, TestValue>) -> RequestBuilder<Entity, PredicateStep, Output> {

        guard let predicateFormat = request.predicate?.predicateFormat else { return .init(request: request) }

        let newPredicateFormat = "\(predicateFormat) OR \(predicate.nsValue.predicateFormat)"
        request.predicate = NSPredicate(format: newPredicateFormat)
        return self
    }

    /// Advanced comparison predicate
    /// ### Examples
    /// - `.or(\.keyPath, .isIn(1...100))`
    /// - `.or(\.keyPath, .hasPrefix("Mon"))`
    func or<Value: DatabaseFieldValue & Equatable, TestValue>(
        _ keyPath: KeyPath<Entity, Value>,
        _ predicateRightValue: PredicateRightValue<Entity, Value, TestValue>)
    -> RequestBuilder<Entity, PredicateStep, Output> {

        guard let predicateFormat = request.predicate?.predicateFormat else { return .init(request: request) }

        let newPredicateFormat = "\(predicateFormat) OR \(predicateRightValue.predicate(keyPath).nsValue)"
        request.predicate = NSPredicate(format: newPredicateFormat)
        return self
    }

    /// Basic comparison predicate
    /// ### Examples
    ///  - `.and(\.keyPath == "Value")`
    ///  - `.and(\.keyPath >= 20)`
    func and<Value: DatabaseFieldValue, TestValue>(_ predicate: Predicate<Entity, Value, TestValue>) -> RequestBuilder<Entity, PredicateStep, Output> {

        guard let predicateFormat = request.predicate?.predicateFormat else { return .init(request: request) }

        let newPredicateFormat = "(\(predicateFormat)) AND \(predicate.nsValue.predicateFormat)"
        request.predicate = NSPredicate(format: newPredicateFormat)
        return self
    }

    /// Advanced comparison predicate
    /// ### Examples
    /// - `.and(\.keyPath, .isIn(1...100))`
    /// - `.and(\.keyPath, .hasPrefix("Mon"))`
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

// MARK: Sort

public extension RequestBuilder {

    enum SortDirection {
        case ascending, descending
    }
}

public extension RequestBuilder where Step: SortableStep {

    /// Add a sort descriptor to the request for the given direction and key path
    func sorted<Value: DatabaseFieldValue & Comparable>(by direction: SortDirection, _ keyPath: KeyPath<Entity, Value>) -> RequestBuilder<Entity, SortStep, Output> {
        let descriptor = NSSortDescriptor(key: keyPath.label, ascending: direction == .ascending)
        request.sortDescriptors = [descriptor]
        return .init(request: request)
    }

    /// Add a sort descriptor to the request for the given direction and key path
    func sorted<Value: DatabaseFieldValue & Comparable>(by direction: SortDirection, _ keyPath: KeyPath<Entity, Value?>) -> RequestBuilder<Entity, SortStep, Output> {
        let descriptor = NSSortDescriptor(key: keyPath.label, ascending: direction == .ascending)
        request.sortDescriptors = [descriptor]
        return .init(request: request)
    }
}

public extension RequestBuilder where Step == SortStep {

    /// Add an additional sort descriptor to the request for the given direction and key path
    func then<Value: DatabaseFieldValue & Comparable>(by direction: SortDirection, _ keyPath: KeyPath<Entity, Value>) -> RequestBuilder<Entity, SortStep, Output> {
        let descriptor = NSSortDescriptor(key: keyPath.label, ascending: direction == .ascending)
        request.sortDescriptors = (request.sortDescriptors ?? []) + [descriptor]
        return self
    }

    /// Add an additional sort descriptor to the request for the given direction and key path
    func then<Value: DatabaseFieldValue & Comparable>(by direction: SortDirection, _ keyPath: KeyPath<Entity, Value?>) -> RequestBuilder<Entity, SortStep, Output> {
        let descriptor = NSSortDescriptor(key: keyPath.label, ascending: direction == .ascending)
        request.sortDescriptors = (request.sortDescriptors ?? []) + [descriptor]
        return self
    }
}
