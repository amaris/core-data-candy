//
// CoreDataCandy
// Copyright © 2018-present Amaris Software.
// MIT license, see LICENSE file for details

/// Wrapper for a `DatabaseEntity` to hide its access publicly
public struct EntityWrapper<Entity: DatabaseEntity> {
    let entity: Entity

    public init(entity: Entity) {
        self.entity = entity
    }
}
