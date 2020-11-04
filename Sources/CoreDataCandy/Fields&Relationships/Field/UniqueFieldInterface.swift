//
// Copyright © 2018-present Amaris Software.
//

import CoreData

/// A field that has to be is unique in the entity table
public struct UniqueFieldInterface<FieldValue: DatabaseFieldValue & Equatable, Value, Entity: FetchableEntity, OutputError: ConversionError, StoreError: Error>: FieldInterfaceProtocol {

    // MARK: - Constants

    public typealias OutputConversion = (FieldValue) -> Result<Value, OutputError>
    public typealias StoreConversion = (Value) -> Result<FieldValue, StoreError>

    // MARK: - Properties

    public let keyPath: ReferenceWritableKeyPath<Entity, FieldValue>
    public let defaultValue: Value?
    public let outputConversion: OutputConversion
    public let storeConversion: StoreConversion
    public let validation: Validation<Value>

    // MARK: - Initialisation

    public init(_ keyPath: ReferenceWritableKeyPath<Entity, FieldValue>, defaultValue: Value?,
         outputConversion: @escaping OutputConversion, storeConversion: @escaping StoreConversion,
         validations: [Validation<Value>]) {
        self.keyPath = keyPath
        self.defaultValue = defaultValue
        self.outputConversion = outputConversion
        self.storeConversion = storeConversion
        self.validation = Validation<Value> { value in
            try validations.forEach {
                try $0.validate(value)
            }
        }
    }

    // MARK: - Functions

    public func set(_ value: Value, on entity: Entity) throws {
        try validate(value)

        guard let context = entity.managedObjectContext else {
            assertionFailure("No context accessible for entity \(Entity.self) when setting its value")
            return
        }

        entity[keyPath: keyPath] = try uniqueStoredValue(for: value, in: context)
    }

    /// Returns the given value as a stored `FieldValue` while ensuring its unicity
    @discardableResult
    func uniqueStoredValue(for value: Value, in context: NSManagedObjectContext) throws -> FieldValue {
        let storeConverted = storeConversion(value)
        let storedValue: FieldValue

        switch storeConverted {
        case .success(let value): storedValue = value
        case .failure(let error): throw error
        }

        if try Entity.fetch(.first(), where: keyPath == storedValue, in: context) != nil {
            let field = keyPath.label.components(separatedBy: ".").last ?? ""
            throw CoreDataCandyError.existingUnique(field: field, value: String(describing: value), model: Entity.modelName)
        }

        return storedValue
    }
}

public extension DatabaseModel where Entity: FetchableEntity {

    /// A field that has to be unique in the entity when compared to others
    typealias
        UniqueField<FieldValue: DatabaseFieldValue & Equatable, Value, OutputError: ConversionError, StoreError: Error>
        =
        UniqueFieldInterface<FieldValue, Value, Entity, OutputError, StoreError>
}
