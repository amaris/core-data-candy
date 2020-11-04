//
// Copyright © 2018-present Amaris Software.
//

import Foundation

public struct Sort<Entity: FetchableEntity, Value: Comparable> {
    let keyPath: KeyPath<Entity, Value?>
    private let comparison: (Value, Value) -> Bool

    func compare(_ valueA: Value?, _ valueB: Value?) -> Bool {
        switch (valueA, valueB) {
        case (.some(let a), .some(let b)): return comparison(a, b)
        case (.some, .none): return true
        case (.none, .some): return false
        case (nil, nil): return true
        }
    }
}

public extension Sort {

    static func ascending<Entity: FetchableEntity, Value: Comparable>(_ keyPath: KeyPath<Entity, Value?>) -> Sort<Entity, Value> {
        Sort<Entity, Value>(keyPath: keyPath, comparison: <)
    }

    static func descending<Entity: FetchableEntity, Value: Comparable>(_ keyPath: KeyPath<Entity, Value?>) -> Sort<Entity, Value> {
        Sort<Entity, Value>(keyPath: keyPath, comparison: >)
    }
}
