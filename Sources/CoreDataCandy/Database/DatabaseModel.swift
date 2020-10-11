//
// Copyright © 2018-present Amaris Software.
//

import CoreData
import Combine

/// Holds a CoreData entity and hide the work with the CoreData context while offering Swift types to work with
public protocol DatabaseModel {
    associatedtype Entity: NSManagedObject & DatabaseEntity

    var context: NSManagedObjectContext { get }
    var entity: Entity { get }

    init(entity: Entity, context: NSManagedObjectContext)
}

public extension DatabaseModel {
    typealias Field<FieldValue: DatabaseFieldValue, Value, OutputError: ConversionError, StoreError: Error> = FieldWrapper<FieldValue, Value, Entity, OutputError, StoreError>

    /// Pass `context` and `entity`  to the field properties for them to interact with the database
    func setupFields() {
        let mirror = Mirror(reflecting: self)

        mirror.children.forEach { (child) in
            if let field = child.value as? FieldAbstract<Entity> {
                field.entity = entity
            }
        }
    }

    /// Return a `DatabaseModel` wrapping the first entity found with the given criterias
    static func fetch<V>(for field: KeyPath<Entity,V>, value: V, in context: NSManagedObjectContext) throws -> Self? {
        let request = Entity.fetch
        request.predicate = .keyPath(field, equals: value)
        let results = try context.fetch(request)

        guard let entity = results.first else { return nil }

        let model = Self.init(entity: entity, context: context)
        return model
    }

    func assign<F: FieldPublisher, Value>(_ value: Value, to keyPath: KeyPath<Self, F>) throws where F.Value == Value {
        let field = self[keyPath: keyPath]
        try field.store(value)
        do {
            try context.save()
        } catch {
            throw CoreDataCandyError.unableToSaveContext(reason: error.localizedDescription)
        }
    }

    func publisher<Value, E, F: FieldPublisher>(for keyPath: KeyPath<Self, F>) -> AnyPublisher<Value, E>
    where Value == F.Value, E == F.OutputError  {
        self[keyPath: keyPath].publisher
    }
}
