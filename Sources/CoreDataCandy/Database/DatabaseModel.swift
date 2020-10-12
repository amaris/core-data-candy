//
// Copyright © 2018-present Amaris Software.
//

import CoreData
import Combine

/// Holds a CoreData entity and hide the work with the CoreData context while offering Swift types to work with
public protocol DatabaseModel: class {
    associatedtype Entity: NSManagedObject & DatabaseEntity

    var entity: Entity { get set }

    init(entity: Entity)
}

public extension DatabaseModel {
    typealias
        Field<FieldValue: DatabaseFieldValue, Value, OutputError: ConversionError, StoreError: Error>
        =
        FieldWrapper<FieldValue, Value, Entity, OutputError, StoreError>

    /// Return a `DatabaseModel` wrapping the first entity found with the given criterias
    static func fetch<V: DatabaseFieldValue>(for field: KeyPath<Entity, V>, value: V, in context: NSManagedObjectContext) throws -> Self? {
        let request = Entity.fetch
        request.predicate = .keyPath(field, equals: value)
        let results = try context.fetch(request)

        guard let entity = results.first else { return nil }

        let model = Self.init(entity: entity)
        return model
    }

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
