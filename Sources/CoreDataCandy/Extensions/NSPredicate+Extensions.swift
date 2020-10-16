//
// Copyright © 2018-present Amaris Software.
//

import CoreData

public extension NSPredicate {

    /// KeyPath predicate for an equality with the given value
    static func keyPath<T: DatabaseEntity, V: DatabaseFieldValue>(_ keyPath: KeyPath<T, V>, equals value: V) -> NSPredicate {
        let name = keyPath.label
        return NSPredicate(format: "%K = %@", argumentArray: [name, value])
  }
}
