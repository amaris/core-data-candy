//
// Copyright © 2018-present Amaris Software.
//

import Foundation

public struct Sort<Entity: FetchableEntity, Value> {
    let keyPath: KeyPath<Entity, Value>
    let comparison: (Value, Value) -> Bool
}

public extension Sort {

    static func optionalCompare<V>(with comparison: @escaping (V, V) -> Bool) -> ((V?, V?) -> Bool) { { valueA, valueB in
            switch (valueA, valueB) {
            case (.some(let a), .some(let b)): return comparison(a, b)
            case (.some, .none): return true
            case (.none, .some): return false
            case (nil, nil): return true
            }
        }
    }

    static func ascending<E: FetchableEntity, V: Comparable>(_ keyPath: KeyPath<E, V>) -> Sort<E, V> {
        Sort<E, V>(keyPath: keyPath, comparison: <)
    }

    static func ascending<Entity: FetchableEntity, V: Comparable>(_ keyPath: KeyPath<Entity, V?>) -> Sort<Entity, V?> {
        Sort<Entity, V?>(keyPath: keyPath, comparison: optionalCompare(with: <))
    }

    static func descending<Entity: FetchableEntity, V: Comparable>(_ keyPath: KeyPath<Entity, V>) -> Sort<Entity, V> {
        Sort<Entity, V>(keyPath: keyPath, comparison: >)
    }

    static func descending<Entity: FetchableEntity, V: Comparable>(_ keyPath: KeyPath<Entity, V?>) -> Sort<Entity, V?> {
        Sort<Entity, V?>(keyPath: keyPath, comparison: optionalCompare(with: >))
    }
}

extension Collection where Element: DatabaseModel, Element.Entity: FetchableEntity {

    func sorted<Value>(with sort: Sort<Element.Entity, Value>) -> [Element] {
        sorted { sort.comparison($0._entityWrapper.entity[keyPath: sort.keyPath], $1._entityWrapper.entity[keyPath: sort.keyPath]) }
    }
}
