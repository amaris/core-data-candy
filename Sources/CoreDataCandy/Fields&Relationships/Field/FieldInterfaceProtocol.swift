//
// Copyright © 2018-present Amaris Software.
//

import CoreData
import Combine

/// Protocol to hold the logic of a Field interface
public protocol FieldInterfaceProtocol: FieldPublisher, FieldModifier {

    // MARK: - Constants

    associatedtype FieldValue: DatabaseFieldValue
    typealias OutputConversion = (FieldValue) -> Result<Value, StoreConversionError>
    typealias StoreConversion = (Value) -> Result<FieldValue, StoreConversionError>

    // MARK: - Properties

    /// Key path to the entity property
    var keyPath: ReferenceWritableKeyPath<Entity, FieldValue> { get }

    /// Transform the database field value into the value
    var outputConversion: OutputConversion { get }

    /// Transform the value into the database field value
    var storeConversion: StoreConversion { get }

    /// Allow to validate a value before assigning it to the entity attribute
    var validation: Validation<Value> { get }

    // MARK: - Initialisation

    init(_ keyPath: ReferenceWritableKeyPath<Entity, FieldValue>,
         outputConversion: @escaping OutputConversion, storeConversion: @escaping StoreConversion,
         validations: [Validation<Value>])
}

public extension FieldInterfaceProtocol {

    init<U>(_ keyPath: ReferenceWritableKeyPath<Entity, FieldValue>,
         outputConversion: @escaping OutputConversion, storeConversion: @escaping StoreConversion,
         validations: [Validation<U>])
    where Value == U? {
        let unwrappedValidations = Validation<Value> { value in
            try validations.forEach {
                guard let value = value else { return }
                try $0.validate(value)
            }
        }

        self.init(keyPath, outputConversion: outputConversion, storeConversion: storeConversion, validations: [unwrappedValidations])
    }
}

// MARK: - FieldPublisher

public extension FieldInterfaceProtocol where Entity: NSManagedObject {

    func publisher(for entity: Entity) -> AnyPublisher<Value, Never> {
        entity.publisher(for: keyPath)
            .map { [outputConversion] dbValue in
                let outputValue = outputConversion(dbValue)

                switch outputValue {
                case .success(let value):
                    return value

                case .failure(let error):
                    preconditionFailure("Error while converting \(FieldValue.self) as \(Value.self). \(error.localizedDescription)")
                }
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - FieldModifier

public extension FieldInterfaceProtocol {

    func set(_ value: Value, on entity: Entity) throws {
        try validate(value)
        let storeConverted = storeConversion(value)

        switch storeConverted {
        case .success(let storableValue): entity[keyPath: keyPath] = storableValue
        case .failure: assertionFailure("Unable to convert the value \(value) to a storable type \(FieldValue.self)")
        }
    }

    func validate(_ value: Value) throws {
        try validation.validate(value)
    }
}

public extension FieldInterfaceProtocol where StoreConversionError == Never {

    /// Get the current stored value in the entity
    func currentValue(in entity: Entity) -> Value {
        let fieldValue = entity[keyPath: keyPath]
        let outputConverted = outputConversion(fieldValue)

        switch outputConverted {
        case .success(let value): return value
        case .failure: preconditionFailure("Failure although the error type is 'Never'")
        }
    }
}

// avoid the optional optional
public extension FieldInterfaceProtocol where StoreConversionError == CoreDataCandyError, FieldValue: ExpressibleByNilLiteral, Value: ExpressibleByNilLiteral {

    /// Try to get the current stored value in the entity, which conversion from the stored type can throw
    func currentValue(in entity: Entity) -> Value {
        let fieldValue = entity[keyPath: keyPath]
        let outputConverted = outputConversion(fieldValue)

        switch outputConverted {
        case .success(let value): return value
        case .failure: return nil
        }
    }
}
