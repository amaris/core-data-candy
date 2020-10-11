//
// Copyright © 2018-present Amaris Software.
//

import CoreData
import Combine

public class FieldAbstract<Entity: NSManagedObject> {
    var entity: Entity!
}

@propertyWrapper
public final class FieldWrapper<FieldValue: DatabaseFieldValue, Value, Entity: NSManagedObject, OutputError: ConversionError, StoreError: Error>: FieldAbstract<Entity> {

    // MARK: - Constants

    typealias OutputConversion = (FieldValue) -> Result<Value, OutputError>
    typealias StoreConversion = (Value) -> Result<FieldValue, StoreError>

    // MARK: - Properties

    private var keyPath: WritableKeyPath<Entity, FieldValue>

    /// Transform the data base field value into the value
    private var outputConversion: OutputConversion

    /// Transform the value into the data base field value
    private var storeConversion: StoreConversion

    /// Identify the field when decoding/encoding
    private var name: FieldCodingKey?
    
    public var projectedValue: FieldWrapper { self }

    private var validation: Validation<Value>

    private var defaultValue: Value?

    public var wrappedValue: AnyPublisher<Value, OutputError> {
        entity.publisher(for: keyPath)
            .tryMap { [unowned self] dbValue in
                let outputValue = self.outputConversion(dbValue)

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
}

extension FieldWrapper: FieldPublisher {

    public func store(_ value: Value) throws {
        try validation.validate(value)
        let storeConverted = storeConversion(value)

        switch storeConverted {
        case .success(let storableValue): entity[keyPath: keyPath] = storableValue
        case .failure(let error): throw error
        }
    }

    public var publisher: AnyPublisher<Value, OutputError> { wrappedValue }
}
