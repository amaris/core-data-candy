//
// Copyright © 2018-present Amaris Software.
//

import CoreData

public struct ComparisonPredicate<T: FetchResultEntity, Value: DatabaseFieldValue> {
    let nsValue: NSPredicate
}

public func == <T: FetchResultEntity, V: DatabaseFieldValue & Equatable>(lhs: KeyPath<T, V>, rhs: V) -> ComparisonPredicate<T, V> {
    let name = lhs.label
    let predicate = NSPredicate(format: "%K = %@", argumentArray: [name, rhs])
    return ComparisonPredicate(nsValue: predicate)
}

public func > <T: FetchResultEntity, V: DatabaseFieldValue & Comparable>(lhs: KeyPath<T, V>, rhs: V) -> ComparisonPredicate<T, V> {
    let name = lhs.label
    let predicate = NSPredicate(format: "%K > %@", argumentArray: [name, rhs])
    return ComparisonPredicate(nsValue: predicate)
}

public func >= <T: FetchResultEntity, V: DatabaseFieldValue & Comparable>(lhs: KeyPath<T, V>, rhs: V) -> ComparisonPredicate<T, V> {
    let name = lhs.label
    let predicate = NSPredicate(format: "%K >= %@", argumentArray: [name, rhs])
    return ComparisonPredicate(nsValue: predicate)
}

public func < <T: FetchResultEntity, V: DatabaseFieldValue & Comparable>(lhs: KeyPath<T, V>, rhs: V) -> ComparisonPredicate<T, V> {
    let name = lhs.label
    let predicate = NSPredicate(format: "%K < %@", argumentArray: [name, rhs])
    return ComparisonPredicate(nsValue: predicate)
}

public func <= <T: FetchResultEntity, V: DatabaseFieldValue & Comparable>(lhs: KeyPath<T, V>, rhs: V) -> ComparisonPredicate<T, V> {
    let name = lhs.label
    let predicate = NSPredicate(format: "%K <= %@", argumentArray: [name, rhs])
    return ComparisonPredicate(nsValue: predicate)
}
