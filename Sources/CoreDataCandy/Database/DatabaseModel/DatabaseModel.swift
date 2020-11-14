//
// Copyright © 2018-present Amaris Software.
//

import CoreData
import Combine

public struct EntityWrapper<Entity: DatabaseEntity> {
    internal let entity: Entity

    public init(entity: Entity) {
        self.entity = entity
    }
}

/// Holds a CoreData entity and hide the work with the CoreData context while offering Swift types to work with
public protocol DatabaseModel: Fetchable, Hashable, CustomDebugStringConvertible {
    associatedtype Entity: DatabaseEntity

    var _entityWrapper: EntityWrapper<Entity> { get }

    init<E: NSManagedObject>(entity: E) where E == Entity
}

public extension DatabaseModel where Entity: NSManagedObject {

    func remove() throws {
        let context = _entityWrapper.entity.managedObjectContext
        context?.delete(_entityWrapper.entity)
    }
}

// MARK: - Hashable

public extension DatabaseModel {

    func hash(into hasher: inout Hasher) {
        hasher.combine(_entityWrapper.entity)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs._entityWrapper.entity == rhs._entityWrapper.entity
    }
}

// MARK: - Description

extension DatabaseModel where Entity: NSManagedObject {

    /// Textual representation of the entity attributes
    public var debugDescription: String {
        let entityDescription = _entityWrapper.entity.description

        guard let range = entityDescription.range(of: #"\{(.|\s)+\}"#, options: .regularExpression) else {
            return "Fault data"
        }

        return String(describing: Self.self) + " " + entityDescription[range]
    }
}
