//
// Copyright © 2018-present Amaris Software.
//

/// Relationship one to one
public struct SiblingInterface<Entity: DatabaseEntity, SiblingModel: DatabaseModel>: ParentInterfaceProtocol {
    public typealias ParentModel = SiblingModel

    public let keyPath: ReferenceWritableKeyPath<Entity, SiblingModel.Entity?>

    public init(_ keyPath: ReferenceWritableKeyPath<Entity, SiblingModel.Entity?>, as type: SiblingModel.Type) {
        self.keyPath = keyPath
    }
}

public extension DatabaseModel {

    /// Relationship one to one
    typealias Sibling<SiblingModel: DatabaseModel> = SiblingInterface<Entity, SiblingModel>
}
