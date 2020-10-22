//
// Copyright © 2018-present Amaris Software.
//

import CoreData
import Combine

/// Holds a CoreData field with custom validation and codable logic
public class FieldInterface<FieldValue: DatabaseFieldValue, Value, Entity: FetchableEntity, OutputError: ConversionError, StoreError: Error> {

    // MARK: - Constants

    typealias OutputConversion = (FieldValue) -> Result<Value, OutputError>
    typealias StoreConversion = (Value) -> Result<FieldValue, StoreError>

    // MARK: - Properties

    /// Key path to the entity property
    let keyPath: ReferenceWritableKeyPath<Entity, FieldValue>

    /// The data base model can optionally define a default value to use when `outputConversion` returns a failure
    private var defaultValue: Value?

    /// Transform the data base field value into the value
    let outputConversion: OutputConversion

    /// Transform the value into the data base field value
    let storeConversion: StoreConversion

    public var projectedValue: FieldInterface { self }

    /// Validation to run before setting a value
    public private(set) var validation: Validation<Value>

    // MARK: - Initialisation

    init(_ keyPath: ReferenceWritableKeyPath<Entity, FieldValue>, defaultValue: Value? = nil,
         outputConversion: @escaping OutputConversion, storeConversion: @escaping StoreConversion,
         validations: [Validation<Value>] = []) {
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

    init<U>(_ keyPath: ReferenceWritableKeyPath<Entity, FieldValue>, defaultValue: Value? = nil,
         outputConversion: @escaping OutputConversion, storeConversion: @escaping StoreConversion,
         validations: [Validation<U>] = [])
    where Value == U? {
        self.keyPath = keyPath
        self.defaultValue = defaultValue
        self.outputConversion = outputConversion
        self.storeConversion = storeConversion
        self.validation = Validation<Value> { value in
            try validations.forEach {
                guard let value = value else { return }
                try $0.validate(value)
            }
        }
    }

    public func validate(_ value: Value) throws {
        try validation.validate(value)
    }
}

extension FieldInterface: FieldPublisher {

    public func set(_ value: Value, on entity: Entity) throws {
        try validate(value)
        let storeConverted = storeConversion(value)

        switch storeConverted {
        case .success(let storableValue): entity[keyPath: keyPath] = storableValue
        case .failure(let error): throw error
        }
    }

    public func publisher(for entity: Entity) -> AnyPublisher<Value, OutputError> {
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
