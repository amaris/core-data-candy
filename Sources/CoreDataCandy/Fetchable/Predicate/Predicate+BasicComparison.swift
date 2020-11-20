//
// CoreDataCandy
// Copyright © 2018-present Amaris Software.
// MIT license, see LICENSE file for details

import Foundation

// MARK: Basic predicate comparison

public func == <E: DatabaseEntity, V: DatabaseFieldValue & Equatable>(lhs: KeyPath<E, V>, rhs: V) -> Predicate<E, V, V> {
    .init(keyPath: lhs, operatorString: "==", value: rhs)
}

public func != <E: DatabaseEntity, V: DatabaseFieldValue & Equatable>(lhs: KeyPath<E, V>, rhs: V) -> Predicate<E, V, V> {
    .init(keyPath: lhs, operatorString: "!=", value: rhs)
}

public func > <E: DatabaseEntity, V: DatabaseFieldValue & Comparable>(lhs: KeyPath<E, V>, rhs: V) -> Predicate<E, V, V> {
    .init(keyPath: lhs, operatorString: ">", value: rhs)
}

public func >= <E: DatabaseEntity, V: DatabaseFieldValue & Comparable>(lhs: KeyPath<E, V>, rhs: V) -> Predicate<E, V, V> {
    .init(keyPath: lhs, operatorString: ">=", value: rhs)
}

public func < <E: DatabaseEntity, V: DatabaseFieldValue & Comparable>(lhs: KeyPath<E, V>, rhs: V) -> Predicate<E, V, V> {
    .init(keyPath: lhs, operatorString: "<", value: rhs)
}

public func <= <E: DatabaseEntity, V: DatabaseFieldValue & Comparable>(lhs: KeyPath<E, V>, rhs: V) -> Predicate<E, V, V> {
    .init(keyPath: lhs, operatorString: "<=", value: rhs)
}
