//
// Copyright © 2018-present Amaris Software.
//

import CoreData

/// Holds a CoreData entity and hide the work with the CoreData context while offering Swift types to work with
public protocol DatabaseModel: Fetchable, Hashable, CustomDebugStringConvertible {
    associatedtype Entity: DatabaseEntity

    /// This wrapper will be used internally by the API and cannot be used outside.
    /// Its purpose is to hide the `entity` from the rest of the app.
    /// The only requirement is to instantiate it in the  `init(entity:)` initializer.
    var _entityWrapper: EntityWrapper<Entity> { get }

    /// Instantiate the `DatabaseModel`. It's the oppurtinity to perform
    /// some code on the `entity` if needed, as the `entity` will then be hidden
    /// behind the `_entityWrapper`
    init(entity: Entity)
 }

extension DatabaseModel {

    var entity: Entity { _entityWrapper.entity }
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
