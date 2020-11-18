//
// Copyright © 2018-present Amaris Software.
//

import Foundation

/// Holds a comparison function on a root object
public struct Sort<Root> {
    let comparison: (Root, Root) -> Bool
}

extension Sort {

    /// Take a comparison function and transforms it into a comparison funcrion which works on optionals
    static func optional<V>(_ comparison: @escaping (V, V) -> Bool) -> ((V?, V?) -> Bool) { { valueA, valueB in
            switch (valueA, valueB) {
            case (.some(let a), .some(let b)): return comparison(a, b)
            case (.some, .none): return true
            case (.none, .some): return false
            case (nil, nil): return true
            }
        }
    }

    /// Builds a sort function by combining the given sort functions.
    ///
    /// The built sort function will compare two values, and if the two values are equal,
    /// will use the next sort function to decide, until all sort functions have been used.
    /// - note: Idea from [Advanced Swift - objc.io](https://www.objc.io/books/advanced-swift/)
    static func combine(sorts: [Sort<Root>]) -> Sort<Root> {
        Sort<Root> { (lhs, rhs) in
            for comparison in sorts.map(\.comparison) {
                if comparison(lhs, rhs) { return true }
                if comparison(rhs, lhs) { return false }
            }
            return false
        }
    }
}

public extension Sort {

    private static func sort<R, V>(on keyPah: KeyPath<R, V>, by comparison: @escaping (V, V) -> Bool) -> Sort<R> {
        Sort<R> { comparison($0[keyPath: keyPah], $1[keyPath: keyPah]) }
    }

    static func custom<R, V>(on keyPath: KeyPath<R, V>, using comparison: @escaping (V, V) -> Bool) -> Sort<R> {
        sort(on: keyPath, by: comparison)
    }

    static func custom<R, V>(on keyPath: KeyPath<R, V?>, using comparison: @escaping (V, V) -> Bool) -> Sort<R> {
        sort(on: keyPath, by: optional(comparison))
    }

    /// Default `<` comparison on two comparables
    static func ascending<R, V: Comparable>(_ keyPath: KeyPath<R, V>) -> Sort<R> {
        sort(on: keyPath, by: <)
    }

    /// Default `<` comparison on two comparables
    static func ascending<R, V: Comparable>(_ keyPath: KeyPath<R, V?>) -> Sort<R> {
        sort(on: keyPath, by: optional(<))
    }

    /// Default `>` comparison on two comparables
    static func descending<R, V: Comparable>(_ keyPath: KeyPath<R, V>) -> Sort<R> {
        sort(on: keyPath, by: >)
    }

    /// Default `>` comparison on two comparables
    static func descending<R, V: Comparable>(_ keyPath: KeyPath<R, V?>) -> Sort<R> {
        sort(on: keyPath, by: optional(>))
    }
}

// MARK: Sort integration

extension Collection {
    func sorted(by sorts: [Sort<Element>]) -> [Element] {
        sorted {
            let sort = Sort<Element>.combine(sorts: sorts)
            return sort.comparison($0, $1) }
    }

    func sorted(by sorts: Sort<Element>...) -> [Element] {
        sorted(by: sorts)
    }
}

public extension Collection where Element: DatabaseModel, Element.Entity: FetchableEntity {

    func sorted(by sorts: Sort<Element.Entity>...) -> [Element] {
        sorted(by: sorts)
    }

    func sorted(by sorts: [Sort<Element.Entity>]) -> [Element] {
        sorted {
            let sort = Sort<Element.Entity>.combine(sorts: sorts)
            return sort.comparison($0.entity, $1.entity) }
    }
}
