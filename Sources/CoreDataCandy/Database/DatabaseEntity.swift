//
// Copyright © 2018-present Amaris Software.
//

import CoreData
import Combine

/// Entity in CoreData
public protocol DatabaseEntity: Hashable {
    var managedObjectContext: NSManagedObjectContext? { get }

    init(context moc: NSManagedObjectContext)
}

public extension DatabaseEntity where Self: NSManagedObject {

    /// Hide the `NSManagedObject.publisher(for:)` function
    func attributePublisher<FieldValue: DatabaseFieldValue>(for keyPath: KeyPath<Self, FieldValue>) -> AnyPublisher<FieldValue, Never> {
        publisher(for: keyPath).eraseToAnyPublisher()
    }
}
