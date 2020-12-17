//
// CoreDataCandy
// Copyright © 2018-present Amaris Software.
// MIT license, see LICENSE file for details

import CoreData
import Combine

/// A field that has to be is unique in the entity table
public struct UniqueFieldInterface<FieldValue: DatabaseFieldValue & Equatable, Value, Entity: DatabaseEntity>: FieldInterfaceProtocol, ConversionErrorObservable {

    // MARK: - Constants

    public typealias OutputConversion = (FieldValue) -> Value
    public typealias StoreConversion = (Value) -> FieldValue?

    // MARK: - Properties

    public let keyPath: ReferenceWritableKeyPath<Entity, FieldValue>
    public let outputConversion: OutputConversion
    public let storeConversion: StoreConversion
    public let validation: Validation<Value>

    let errorSubject = PassthroughSubject<ConversionError, Never>()
    public var conversionErrorPublisher: AnyPublisher<ConversionError, Never> { errorSubject.eraseToAnyPublisher() }

    // MARK: - Initialisation

    public init(_ keyPath: ReferenceWritableKeyPath<Entity, FieldValue>,
         outputConversion: @escaping OutputConversion, storeConversion: @escaping StoreConversion,
         validations: [Validation<Value>]) {
        self.keyPath = keyPath
        self.outputConversion = outputConversion
        self.storeConversion = storeConversion
        self.validation = Validation<Value> { value in
            try validations.forEach { try $0.validate(value) }
        }
    }

    // MARK: - Functions

    public func set(_ value: Value, on entity: Entity) throws {
        try validate(value)

        guard let context = entity.managedObjectContext else {
            preconditionFailure("No context accessible for entity \(Entity.self) when setting its value")
        }

        entity[keyPath: keyPath] = try uniqueStoredValue(for: value, in: context)
    }

    /// Returns the given value as a stored `FieldValue` while ensuring its unicity
    @discardableResult
    func uniqueStoredValue(for value: Value, in context: NSManagedObjectContext) throws -> FieldValue {
        guard let storedValue = storeConversion(value) else {
            throw ConversionError(attributeLabel: keyPath.label, description: "Internal error while converting stored value \(value) to \(Value.self)")
        }

        if try Entity.request().first().where(keyPath == storedValue).fetch(in: context) != nil {
            let field = keyPath.label.components(separatedBy: ".").last ?? ""
            throw CoreDataCandyError.existingUnique(field: field, value: String(describing: value), model: Entity.modelName)
        }

        return storedValue
    }
}

public extension DatabaseModel where Entity: DatabaseEntity {

    /// A field that has to be unique in the entity when compared to others
    typealias
        UniqueField<FieldValue: DatabaseFieldValue & Equatable, Value>
        =
        UniqueFieldInterface<FieldValue, Value, Entity>
}
