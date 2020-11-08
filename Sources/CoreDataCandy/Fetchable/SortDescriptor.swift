//
// Copyright © 2018-present Amaris Software.
//

import Foundation

public struct SortDescriptor<Entity: FetchableEntity> {
    public let descriptor: NSSortDescriptor
}

public extension SortDescriptor {

    static func ascending<Value: DatabaseFieldValue & Comparable>(_ keyPath: KeyPath<Entity, Value>) -> SortDescriptor {
        SortDescriptor(descriptor: .init(key: keyPath.label, ascending: true))
    }

    static func ascending<Value: DatabaseFieldValue & Comparable>(_ keyPath: KeyPath<Entity, Value?>) -> SortDescriptor {
        SortDescriptor(descriptor: .init(key: keyPath.label, ascending: true))
    }

    static func descending<Value: DatabaseFieldValue & Comparable>(_ keyPath: KeyPath<Entity, Value>) -> SortDescriptor {
        SortDescriptor(descriptor: .init(key: keyPath.label, ascending: false))
    }

    static func descending<Value: DatabaseFieldValue & Comparable>(_ keyPath: KeyPath<Entity, Value?>) -> SortDescriptor {
        SortDescriptor(descriptor: .init(key: keyPath.label, ascending: false))
    }
}
