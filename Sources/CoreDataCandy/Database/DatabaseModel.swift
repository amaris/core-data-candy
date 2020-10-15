//
// Copyright © 2018-present Amaris Software.
//

import CoreData
import Combine

/// Holds a CoreData entity and hide the work with the CoreData context while offering Swift types to work with
public protocol DatabaseModel: class, Fetchable {
    associatedtype Entity: DatabaseEntity

    var entity: Entity { get set }

    init(entity: Entity)
}

public extension DatabaseModel {
    typealias
        Field<FieldValue: DatabaseFieldValue, Value, OutputError: ConversionError, StoreError: Error>
        =
        FieldWrapper<FieldValue, Value, Entity, OutputError, StoreError>

    /// Assign the output of the upstream to the given field property
    func assign<F: FieldPublisher, Value>(_ value: Value, to keyPath: KeyPath<Self, F>) throws
    where F.Value == Value, F.Entity == Entity {
        let field = self[keyPath: keyPath]
        try field.set(value, on: &entity)
        do {
            try entity.managedObjectContext?.save()
        } catch {
            throw CoreDataCandyError.unableToSaveContext(reason: error.localizedDescription)
        }
    }

    /// Publisher for the given field
    func publisher<Value, E, F: FieldPublisher>(for keyPath: KeyPath<Self, F>) -> AnyPublisher<Value, E>
    where Value == F.Value, E == F.OutputError, F.Entity == Entity {
        self[keyPath: keyPath].publisher(for: entity)
    }
}
