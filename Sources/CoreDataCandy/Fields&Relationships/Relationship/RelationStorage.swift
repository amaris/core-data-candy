//
// Copyright © 2018-present Amaris Software.
//

import Foundation

public protocol RelationStorage {
    init()
    var array: [Any] { get }
    func mutableCopy() -> Any
}

extension NSSet: RelationStorage {
    public var array: [Any] { allObjects }
}

extension NSOrderedSet: RelationStorage {}

public protocol RelationMutableStorage {
    associatedtype Immutable: RelationStorage

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
