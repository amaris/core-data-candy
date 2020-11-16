//
// Copyright © 2018-present Amaris Software.
//

import Foundation

/// Abstract protocol for `NSSet` and `NSOrderedSet` when working with managed object relationships
public protocol RelationStorage {
    init()
    var array: [Any] { get }
    func mutableCopy() -> Any
}

extension NSSet: RelationStorage {
    public var array: [Any] { allObjects }
}

extension NSOrderedSet: RelationStorage {}

/// Abstract protocol for `NSMutableSet` and `NSMutableOrderedSet` when working with managed object relationships
public protocol RelationMutableStorage {
    associatedtype Immutable: RelationStorage

    /// The immutable counterpart of the mutable storage
    var immutable: Immutable { get }

    init()

    func add(_ object: Any)
    func remove(_ object: Any)
}

extension NSMutableSet: RelationMutableStorage {
    public var immutable: NSSet { self as NSSet }
}

extension NSMutableOrderedSet: RelationMutableStorage {
    public var immutable: NSOrderedSet { self as NSOrderedSet }
}
