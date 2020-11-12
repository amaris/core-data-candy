//
// Copyright © 2018-present Amaris Software.
//

import Foundation

// MARK: Basic predicate comparison

public func == <E: DatabaseEntity, V: DatabaseFieldValue & Equatable>(lhs: KeyPath<E, V>, rhs: V) -> Predicate<E, V, V> {
    return Predicate<E, V, V>(keyPath: lhs, operatorString: "==", value: rhs)
}

public func != <E: DatabaseEntity, V: DatabaseFieldValue & Equatable>(lhs: KeyPath<E, V>, rhs: V) -> Predicate<E, V, V> {
    return Predicate<E, V, V>(keyPath: lhs, operatorString: "!=", value: rhs)
}

public func > <E: DatabaseEntity, V: DatabaseFieldValue & Comparable>(lhs: KeyPath<E, V>, rhs: V) -> Predicate<E, V, V> {
    return Predicate<E, V, V>(keyPath: lhs, operatorString: ">", value: rhs)
}

public func >= <E: DatabaseEntity, V: DatabaseFieldValue & Comparable>(lhs: KeyPath<E, V>, rhs: V) -> Predicate<E, V, V> {
    return Predicate<E, V, V>(keyPath: lhs, operatorString: ">=", value: rhs)
}

public func < <E: DatabaseEntity, V: DatabaseFieldValue & Comparable>(lhs: KeyPath<E, V>, rhs: V) -> Predicate<E, V, V> {
    return Predicate<E, V, V>(keyPath: lhs, operatorString: "<", value: rhs)
}

public func <= <E: DatabaseEntity, V: DatabaseFieldValue & Comparable>(lhs: KeyPath<E, V>, rhs: V) -> Predicate<E, V, V> {
    return Predicate<E, V, V>(keyPath: lhs, operatorString: "<=", value: rhs)
}
