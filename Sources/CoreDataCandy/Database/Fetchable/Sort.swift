//
// Copyright © 2018-present Amaris Software.
//

import Foundation

public struct Sort<Entity: FetchableEntity> {
    public let descriptor: NSSortDescriptor
}

public extension Sort {

    static func ascending<Value: DatabaseFieldValue & Comparable>(_ keyPath: KeyPath<Entity, Value>) -> Sort {
        Sort(descriptor: .init(key: keyPath.label, ascending: true))
    }

    static func ascending<Value: DatabaseFieldValue & Comparable>(_ keyPath: KeyPath<Entity, Value?>) -> Sort {
        Sort(descriptor: .init(key: keyPath.label, ascending: true))
    }

    static func descending<Value: DatabaseFieldValue & Comparable>(_ keyPath: KeyPath<Entity, Value>) -> Sort {
        Sort(descriptor: .init(key: keyPath.label, ascending: false))
    }

    static func descending<Value: DatabaseFieldValue & Comparable>(_ keyPath: KeyPath<Entity, Value?>) -> Sort {
        Sort(descriptor: .init(key: keyPath.label, ascending: false))
    }
}
