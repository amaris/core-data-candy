//
// Copyright © 2018-present Amaris Software.
//

import Foundation

public extension Predicate {

    // MARK: Values set

    /// `true` if the property is contained the values
    static func `where`<Value: DatabaseFieldValue & Equatable>(_ keyPath: KeyPath<E, Value>, isIn values: Value...)
    -> Predicate<E, Value, [Value]> {
        .init(keyPath: keyPath, operatorString: "IN", value: values)
    }

    /// `false` if the property is in the values
    static func `where`<Value: DatabaseFieldValue & Equatable>(_ keyPath: KeyPath<E, Value>, isNotIn values: Value...)
    -> Predicate<E, Value, [Value]> {
        .init(keyPath: keyPath, operatorString: "IN", value: values, isInverted: true)
    }

    /// `true` if the property is contained the array
    static func `where`<Value: DatabaseFieldValue & Equatable>(_ keyPath: KeyPath<E, Value>, isIn values: [Value])
    -> Predicate<E, Value, [Value]> {
        .init(keyPath: keyPath, operatorString: "IN", value: values)
    }

    /// `false` if the property is the array
    static func `where`<Value: DatabaseFieldValue & Equatable>(_ keyPath: KeyPath<E, Value>, isNotIn values: [Value])
    -> Predicate<E, Value, [Value]> {
        .init(keyPath: keyPath, operatorString: "IN", value: values, isInverted: true)
    }

    // MARK: Range

    /// `true` if the property is contained the closed range
    static func `where`<Value: DatabaseFieldValue & Comparable>(_ keyPath: KeyPath<E, Value>, isIn range: ClosedRange<Value>)
    -> Predicate<E, Value, [Value]> {
        .init(keyPath: keyPath, operatorString: "BETWEEN", value: [range.lowerBound, range.upperBound])
    }

    /// `false` if the property is contained the closed range
    static func `where`<Value: DatabaseFieldValue & Comparable>(_ keyPath: KeyPath<E, Value>, isNotIn range: ClosedRange<Value>)
    -> Predicate<E, Value, [Value]> {
        .init(keyPath: keyPath, operatorString: "BETWEEN", value: [range.lowerBound, range.upperBound], isInverted: true)
    }

    /// `true` if the property is contained the given range
    static func `where`<Value: DatabaseFieldValue & Comparable>(_ keyPath: KeyPath<E, Value>, isIn range: Range<Value>)
    -> Predicate<E, Value, [Value]> {
        .init(keyPath: keyPath, value: [range.lowerBound, range.upperBound]) { "%@ <= \($0) AND \($0) < %@" }
            argumentsOrder: { [range.lowerBound, $0, $0, range.upperBound] }
    }

    /// `false` if the property is contained the given range
    static func `where`<Value: DatabaseFieldValue & Comparable>(_ keyPath: KeyPath<E, Value>, isNotIn range: Range<Value>)
    -> Predicate<E, Value, [Value]> {
        .init(keyPath: keyPath, value: [range.lowerBound, range.upperBound]) { "%@ > \($0) OR \($0) >= %@" }
            argumentsOrder: { [range.lowerBound, $0, $0, range.upperBound] }
    }
}
