//
// Copyright © 2018-present Amaris Software.
//

import CoreData
import Combine

/// Holds a CoreData entity and hide the work with the CoreData context while offering Swift types to work with
public protocol DatabaseModel: Fetchable, Hashable, CustomDebugStringConvertible {
    associatedtype Entity: DatabaseEntity

    var entity: Entity { get }

    init<E: NSManagedObject>(entity: E) where E == Entity
}

public extension DatabaseModel where Entity: NSManagedObject {

    func remove() throws {
        let context = entity.managedObjectContext
        context?.delete(entity)
    }
}

// MARK: - Hashable

public extension DatabaseModel {

    func hash(into hasher: inout Hasher) {
        hasher.combine(entity)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.entity == rhs.entity
    }
}

// MARK: - Description

extension DatabaseModel where Entity: NSManagedObject {

    /// Textual representation of the entity attributes
    public var debugDescription: String {
        let entityDescription = entity.description

        guard let range = entityDescription.range(of: #"\{(.|\s)+\}"#, options: .regularExpression) else {
            return "Fault data"
        }

        return String(describing: Self.self) + " " + entityDescription[range]
    }
}
