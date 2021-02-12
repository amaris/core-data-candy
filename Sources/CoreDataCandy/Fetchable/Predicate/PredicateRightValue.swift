//
// CoreDataCandy
// Copyright © 2018-present Amaris Software.
// MIT license, see LICENSE file for details

import CoreData

/// An operator and its right operand for a predicate, with no key path.
public struct PredicateRightValue<Entity: NSManagedObject, Value: DatabaseFieldValue, TestValue> {
    public typealias PredicateExpression = (KeyPath<Entity, Value>) -> Predicate<Entity, Value, TestValue>

    public let predicate: PredicateExpression

    public init(predicate: @escaping PredicateExpression) {
        self.predicate = predicate
    }
}

// MARK: - Values set

public extension PredicateRightValue where Value: Equatable {

    // MARK: Values set

    static func isIn(_ values: Value...) -> PredicateRightValue<Entity, Value, [Value]> {
        .init { .init(keyPath: $0, operatorString: "IN", value: values) }
    }

    static func isNotIn(_ values: Value...) -> PredicateRightValue<Entity, Value, [Value]> {
        .init { .init(keyPath: $0, operatorString: "IN", value: values, isInverted: true) }
    }

    static func isIn(_ values: [Value]) -> PredicateRightValue<Entity, Value, [Value]> {
        .init { .init(keyPath: $0, operatorString: "IN", value: values) }
    }

    static func isNotIn(_ values: [Value]) -> PredicateRightValue<Entity, Value, [Value]> {
        .init { .init(keyPath: $0, operatorString: "IN", value: values, isInverted: true) }
    }
}

// MARK: - Range

public extension PredicateRightValue where Value: Numeric & Comparable {

    static func isIn(_ range: ClosedRange<Value>) -> PredicateRightValue<Entity, Value, [Value]> {
        .init { .init(keyPath: $0, operatorString: "BETWEEN", value: [range.lowerBound, range.upperBound]) }
    }

    static func isNotIn(_ range: ClosedRange<Value>) -> PredicateRightValue<Entity, Value, [Value]> {
        .init { .init(keyPath: $0, operatorString: "BETWEEN", value: [range.lowerBound, range.upperBound], isInverted: true) }
    }

    static func isIn(_ range: Range<Value>) -> PredicateRightValue<Entity, Value, [Value]> {
        .init {
            .init(keyPath: $0, value: [range.lowerBound, range.upperBound]) { "%@ <= \($0) AND \($0) < %@" }
                argumentsOrder: { [range.lowerBound, $0, $0, range.upperBound] }
        }
    }

    static func isNotIn(_ range: Range<Value>) -> PredicateRightValue<Entity, Value, [Value]> {
        .init {
            .init(keyPath: $0, value: [range.lowerBound, range.upperBound]) { "%@ > \($0) OR \($0) >= %@" }
                argumentsOrder: { [range.lowerBound, $0, $0, range.upperBound] }
        }
    }
}

// MARK: - String

public extension PredicateRightValue where Value == String? {

    static func hasPrefix(_ prefix: String) -> PredicateRightValue<Entity, Value, String> {
        .init { .init(keyPath: $0, operatorString: "BEGINSWITH", value: prefix) }
    }

    static func hasNoPrefix(_ prefix: String) -> PredicateRightValue<Entity, Value, String> {
        .init { .init(keyPath: $0, operatorString: "BEGINSWITH", value: prefix, isInverted: true) }
    }

    static func hasSuffix(_ suffix: String) -> PredicateRightValue<Entity, Value, String> {
        .init { .init(keyPath: $0, operatorString: "ENDSWITH", value: suffix) }
    }

    static func hasNoSuffix(_ suffix: String) -> PredicateRightValue<Entity, Value, String> {
        .init { .init(keyPath: $0, operatorString: "ENDSWITH", value: suffix, isInverted: true) }
    }

    static func contains(_ other: String) -> PredicateRightValue<Entity, Value, String> {
        .init { .init(keyPath: $0, operatorString: "CONTAINS", value: other) }
    }

    static func doesNotContain(_ other: String) -> PredicateRightValue<Entity, Value, String> {
        .init { .init(keyPath: $0, operatorString: "CONTAINS", value: other, isInverted: true) }
    }

    static func matches(_ pattern: RegularExpressionPattern) -> PredicateRightValue<Entity, Value, String> {
        .init { .init(keyPath: $0, operatorString: "MATCHES", value: pattern.stringValue) }
    }

    static func doesNotMatch(_ pattern: RegularExpressionPattern) -> PredicateRightValue<Entity, Value, String> {
        .init { .init(keyPath: $0, operatorString: "MATCHES", value: pattern.stringValue, isInverted: true) }
    }
}
