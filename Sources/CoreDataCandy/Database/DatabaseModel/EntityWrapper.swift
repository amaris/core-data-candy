//
// Copyright © 2018-present Amaris Software.
//

/// Wrapper for a `DatabaseEntity` to hide its access publicly
public struct EntityWrapper<Entity: DatabaseEntity> {
    let entity: Entity

    public init(entity: Entity) {
        self.entity = entity
    }
}
