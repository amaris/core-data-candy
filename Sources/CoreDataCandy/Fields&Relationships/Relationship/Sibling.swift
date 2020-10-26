//
// Copyright © 2018-present Amaris Software.
//

import Foundation
import Combine

/// Relationship one to one
public struct SiblingInterface<Entity: DatabaseEntity, SiblingModel: DatabaseModel> {

    let keyPath: ReferenceWritableKeyPath<Entity, SiblingModel.Entity?>

    init(_ keyPath: ReferenceWritableKeyPath<Entity, SiblingModel.Entity?>, as type: SiblingModel.Type) {
        self.keyPath = keyPath
    }
}

extension DatabaseModel {

    public typealias Interface<SiblingModel: DatabaseModel> = SiblingInterface<Entity, SiblingModel>
}
