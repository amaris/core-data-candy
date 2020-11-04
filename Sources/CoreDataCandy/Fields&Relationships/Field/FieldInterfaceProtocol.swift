//
// Copyright © 2018-present Amaris Software.
//

import CoreData
import Combine

/// Protocol to hold the logic of a Field interface
public protocol FieldInterfaceProtocol: FieldPublisher, FieldModifier {

    // MARK: - Constants

    associatedtype FieldValue: DatabaseFieldValue
    associatedtype StoreError: Error
    typealias OutputConversion = (FieldValue) -> Result<Value, OutputError>
    typealias StoreConversion = (Value) -> Result<FieldValue, StoreError>

    // MARK: - Properties

    /// Key path to the entity property
    var keyPath: ReferenceWritableKeyPath<Entity, FieldValue> { get }

    /// The data base model can optionally define a default value to use when `outputConversion` returns a failure
    var defaultValue: Value? { get }

    /// Transform the database field value into the value
    var outputConversion: OutputConversion { get }

    /// Transform the value into the database field value
    var storeConversion: StoreConversion { get }

    /// Allow to validate a value before assigning it to the entity attribute
    var validation: Validation<Value> { get }

    // MARK: - Initialisation

    init(_ keyPath: ReferenceWritableKeyPath<Entity, FieldValue>, defaultValue: Value?,
         outputConversion: @escaping OutputConversion, storeConversion: @escaping StoreConversion,
         validations: [Validation<Value>])
}

public extension FieldInterfaceProtocol {

    init<U>(_ keyPath: ReferenceWritableKeyPath<Entity, FieldValue>, defaultValue: Value?,
         outputConversion: @escaping OutputConversion, storeConversion: @escaping StoreConversion,
         validations: [Validation<U>])
    where Value == U? {
        let unwrappedValidations = Validation<Value> { value in
            try validations.forEach {
                guard let value = value else { return }
                try $0.validate(value)
            }
        }

        self.init(keyPath, defaultValue: defaultValue, outputConversion: outputConversion, storeConversion: storeConversion, validations: [unwrappedValidations])
    }
}

// MARK: - FieldPublisher

public extension FieldInterfaceProtocol where Entity: NSManagedObject {

    func publisher(for entity: Entity) -> AnyPublisher<Value, OutputError> {
        entity.publisher(for: keyPath)
            .tryMap { [outputConversion, defaultValue] dbValue in
                let outputValue = outputConversion(dbValue)

                switch outputValue {
                case .success(let value):
                    return value
                case .failure(let error):
                    if let value = defaultValue {
                        return value
                    } else {
                        throw error
                    }
                }
            }
            .mapError { $0 as? OutputError ?? .unknown }
            .eraseToAnyPublisher()
    }
}

// MARK: - FieldModifier

public extension FieldInterfaceProtocol {

    func currentValue(in entity: Entity) throws -> Value {
        let fieldValue = entity[keyPath: keyPath]
        let outputConverted = outputConversion(fieldValue)
        switch outputConverted {
        case .success(let value): return value
        case .failure(let error): throw error
        }
    }

    func set(_ value: Value, on entity: Entity) throws {
        try validate(value)
        let storeConverted = storeConversion(value)

        switch storeConverted {
        case .success(let storableValue): entity[keyPath: keyPath] = storableValue
        case .failure(let error): throw error
        }
    }

    func validate(_ value: Value) throws {
        try validation.validate(value)
    }
}