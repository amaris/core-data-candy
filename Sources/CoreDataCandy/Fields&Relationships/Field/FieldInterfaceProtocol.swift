//
// Copyright © 2018-present Amaris Software.
//

import CoreData
import Combine

/// Protocol to hold the logic of a Field interface
public protocol FieldInterfaceProtocol: FieldPublisher, FieldModifier {

    // MARK: - Constants

    associatedtype FieldValue: DatabaseFieldValue
    typealias OutputConversion = (FieldValue) -> Value
    typealias StoreConversion = (Value) -> FieldValue

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
            .map { [outputConversion] dbValue in outputConversion(dbValue) }
            .eraseToAnyPublisher()
    }
}

// MARK: - FieldModifier

public extension FieldInterfaceProtocol {

    func set(_ value: Value, on entity: Entity) {
        entity[keyPath: keyPath] = storeConversion(value)
    }

    func validate(_ value: Value) throws {
        try validation.validate(value)
    }
}

public extension FieldInterfaceProtocol {

    /// Get the current stored value in the entity
    func currentValue(in entity: Entity) -> Value {
        let fieldValue = entity[keyPath: keyPath]
        return outputConversion(fieldValue)
    }
}
