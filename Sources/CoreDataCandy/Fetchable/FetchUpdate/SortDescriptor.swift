//
// Copyright © 2018-present Amaris Software.
//

import Foundation

/// Wrapper around `NSSortDescriptor`
public struct SortDescriptor<Entity: DatabaseEntity> {
    public let descriptor: NSSortDescriptor
}

public extension SortDescriptor {

    // MARK: Ascending

    static func ascending<Value: DatabaseFieldValue & Comparable>(_ keyPath: KeyPath<Entity, Value>) -> SortDescriptor {
        SortDescriptor(descriptor: .init(key: keyPath.label, ascending: true))
    }

    static func ascending<Value: DatabaseFieldValue & Comparable>(_ keyPath: KeyPath<Entity, Value?>) -> SortDescriptor {
        SortDescriptor(descriptor: .init(key: keyPath.label, ascending: true))
    }

    static func ascending<Value: DatabaseFieldValue>(_ keyPath: KeyPath<Entity, Value>, using comparator: @escaping Comparator) -> SortDescriptor {
        SortDescriptor(descriptor: .init(key: keyPath.label, ascending: true, comparator: comparator))
    }

    static func ascending<Value: DatabaseFieldValue>(_ keyPath: KeyPath<Entity, Value>, using selector: Selector) -> SortDescriptor {
        SortDescriptor(descriptor: .init(key: keyPath.label, ascending: true, selector: selector))
    }

    // MARK: Descending

    static func descending<Value: DatabaseFieldValue & Comparable>(_ keyPath: KeyPath<Entity, Value>) -> SortDescriptor {
        SortDescriptor(descriptor: .init(key: keyPath.label, ascending: false))
    }

    static func descending<Value: DatabaseFieldValue & Comparable>(_ keyPath: KeyPath<Entity, Value?>) -> SortDescriptor {
        SortDescriptor(descriptor: .init(key: keyPath.label, ascending: false))
    }

    static func descending<Value: DatabaseFieldValue>(_ keyPath: KeyPath<Entity, Value>, using comparator: @escaping Comparator) -> SortDescriptor {
        SortDescriptor(descriptor: .init(key: keyPath.label, ascending: false, comparator: comparator))
    }

    static func descending<Value: DatabaseFieldValue>(_ keyPath: KeyPath<Entity, Value>, using selector: Selector) -> SortDescriptor {
        SortDescriptor(descriptor: .init(key: keyPath.label, ascending: false, selector: selector))
    }
}
