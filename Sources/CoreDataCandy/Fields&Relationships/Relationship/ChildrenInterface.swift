//
// CoreDataCandy
// Copyright © 2018-present Amaris Software.
// MIT license, see LICENSE file for details

import Foundation
import CoreData
import Combine

/// Relationship one to many
public struct ChildrenInterface<Entity: DatabaseEntity, ChildModel: DatabaseModel>: ChildrenInterfaceProtocol {

    // MARK: - Constants

    public typealias MutableStorage = NSMutableSet

    // MARK: - Properties

    public let keyPath: ReferenceWritableKeyPath<Entity, NSSet?>

    // MARK: - Initialisation

    public init(_ keyPath: ReferenceWritableKeyPath<Entity, NSSet?>, as type: ChildModel.Type) {
        self.keyPath = keyPath
    }
}

extension ChildrenInterface: FieldPublisher where
    Entity: NSManagedObject,
    ChildModel.Entity: NSManagedObject {}

public extension DatabaseModel {

    /// Relationship one to many
    typealias Children<ChildModel: DatabaseModel> = ChildrenInterface<Entity, ChildModel>
}
