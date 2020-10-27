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

extension DatabaseModel {

    func saveEntityContext() throws {
        guard entity.managedObjectContext?.hasChanges ?? true else {
            return
        }

        do {
            try entity.managedObjectContext?.save()
        } catch {
            throw CoreDataCandyError.unableToSaveContext(reason: error.localizedDescription)
        }
    }
}

public extension DatabaseModel where Entity: NSManagedObject {

    func remove() throws {
        let context = entity.managedObjectContext
        context?.delete(entity)
        try saveEntityContext()
    }
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

public extension DatabaseModel {

    /// The current value of the given field
    func currentValue<F: FieldModifier>(for keyPath: KeyPath<Self, F>) throws -> F.Value where F.Entity == Entity {
        try self[keyPath: keyPath].currentValue(in: entity)
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
