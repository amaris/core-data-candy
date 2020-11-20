//
// CoreDataCandy
// Copyright © 2018-present Amaris Software.
// MIT license, see LICENSE file for details

/// Relationship many to one
public struct ParentInterface<Entity: DatabaseEntity, ParentModel: DatabaseModel>: ParentInterfaceProtocol {

    public let keyPath: ReferenceWritableKeyPath<Entity, ParentModel.Entity?>

    public init(_ keyPath: ReferenceWritableKeyPath<Entity, ParentModel.Entity?>, as type: ParentModel.Type) {
        self.keyPath = keyPath
    }
}

public extension DatabaseModel {

    /// Relationship many to one
    typealias Parent<ParentModel: DatabaseModel> = ParentInterface<Entity, ParentModel>
}
