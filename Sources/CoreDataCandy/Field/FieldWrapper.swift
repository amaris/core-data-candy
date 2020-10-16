//
// Copyright © 2018-present Amaris Software.
//

import CoreData
import Combine

/// Holds a CoreData field with custom validation and codable logic
public struct FieldWrapper<FieldValue: DatabaseFieldValue, Value, Entity: NSManagedObject, OutputError: ConversionError, StoreError: Error> {

    // MARK: - Constants

    typealias OutputConversion = (FieldValue) -> Result<Value, OutputError>
    typealias StoreConversion = (Value) -> Result<FieldValue, StoreError>

    // MARK: - Properties

    /// Key path to the entity property
    private var keyPath: WritableKeyPath<Entity, FieldValue>

    /// The data base model can optionally define a default value to use when `outputConversion` returns a failure
    private var defaultValue: Value?

    /// Transform the data base field value into the value
    private var outputConversion: OutputConversion

    /// Transform the value into the data base field value
    private var storeConversion: StoreConversion

    /// Identify the field when decoding/encoding
    private var name: FieldCodingKey?

    public var projectedValue: FieldWrapper { self }

    /// Validation to run before setting a value
    private var validation: Validation<Value>

    init(_ keyPath: WritableKeyPath<Entity, FieldValue>, name: FieldCodingKey?, defaultValue: Value? = nil,
         outputConversion: @escaping OutputConversion, storeConversion: @escaping StoreConversion,
         validations: [Validation<Value>] = []) {
        self.keyPath = keyPath
        self.name = name
        self.defaultValue = defaultValue
        self.outputConversion = outputConversion
        self.storeConversion = storeConversion
        self.validation = Validation<Value> { value in
            try validations.forEach {
                try $0.validate(value)
            }
        }
    }

    init<U>(_ keyPath: WritableKeyPath<Entity, FieldValue>, name: FieldCodingKey?, defaultValue: Value? = nil,
         outputConversion: @escaping OutputConversion, storeConversion: @escaping StoreConversion,
         validations: [Validation<U>] = [])
    where Value == U? {
        self.keyPath = keyPath
        self.name = name
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
}

extension FieldWrapper: FieldPublisher {

    public func set(_ value: Value, on entity: inout Entity) throws {
        try validation.validate(value)
        let storeConverted = storeConversion(value)

        switch storeConverted {
        case .success(let storableValue): entity[keyPath: keyPath] = storableValue
        case .failure(let error): throw error
        }
    }

    public func publisher(for entity: Entity) -> AnyPublisher<Value, OutputError> {
        entity.publisher(for: keyPath)
            .tryMap { dbValue in
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
