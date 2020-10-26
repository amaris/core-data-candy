//
// Copyright © 2018-present Amaris Software.
//

import CoreData
import Combine

/// Holds a CoreData entity and hide the work with the CoreData context while offering Swift types to work with
public protocol DatabaseModel: Fetchable, Hashable {
    associatedtype Entity: DatabaseEntity

    var entity: Entity { get }

    init<E: NSManagedObject>(entity: E) where E == Entity
}

public extension DatabaseModel {

    // MARK: - Constants

    typealias
        Field<FieldValue: DatabaseFieldValue, Value, OutputError: ConversionError, StoreError: Error>
        =
        FieldInterface<FieldValue, Value, Entity, OutputError, StoreError>

    // MARK: - Functions

    /// Assign the output of the upstream to the given field property
    func assign<F: FieldModifier, Value>(_ value: Value, to keyPath: KeyPath<Self, F>)
    throws
    where F.Value == Value, F.Entity == Entity {
        let field = self[keyPath: keyPath]
        try field.set(value, on: entity)
        do {
            try entity.managedObjectContext?.save()
        } catch {
            throw CoreDataCandyError.unableToSaveContext(reason: error.localizedDescription)
        }
    }

    /// Try to toggle the boolean at the given key path
    func toggle<F: FieldModifier>(_ keyPath: KeyPath<Self, F>)
    throws
    where F.Value == Bool, F.Entity == Entity {
        let field = self[keyPath: keyPath]
        try field.toggle(on: entity)
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

public extension DatabaseModel where Entity: FetchableEntity {
    typealias
        UniqueField<FieldValue: DatabaseFieldValue & Equatable, Value, OutputError: ConversionError, StoreError: Error>
        =
        UniqueFieldInterface<FieldValue, Value, Entity, OutputError, StoreError>
}

// MARK: - Hashable

public extension DatabaseModel {

    func hash(into hasher: inout Hasher) {
        hasher.combine(entity)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.entity == rhs.entity
    }
}

// MARK: - Validation

public extension DatabaseModel where Entity: NSManagedObject {

    static func validate<Value, F: FieldModifier>(value: Value, for keyPath: KeyPath<Self, F>)
    throws
    where Value == F.Value {
        let entity = Entity(context: .init(concurrencyType: .mainQueueConcurrencyType))
        let model = Self(entity: entity)
        try model[keyPath: keyPath].validate(value)
    }
}
