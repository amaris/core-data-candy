//
// Copyright © 2018-present Amaris Software.
//

/// Relationship many to one
public struct ParentInterface<Entity: DatabaseEntity, ParentModel: DatabaseModel> {

    let keyPath: ReferenceWritableKeyPath<Entity, ParentModel.Entity?>

    init(_ keyPath: ReferenceWritableKeyPath<Entity, ParentModel.Entity?>, as type: ParentModel.Type) {
        self.keyPath = keyPath
    }
}

extension DatabaseModel {

    public typealias Parent<ParentModel: DatabaseModel> = ParentInterface<Entity, ParentModel>
}
