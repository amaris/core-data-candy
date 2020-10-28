//
// Copyright © 2018-present Amaris Software.
//

import CoreData

/// Holds a CoreData field/attribute with custom validation and conversion logic
public struct FieldInterface<FieldValue: DatabaseFieldValue, Value, Entity: DatabaseEntity, OutputError: ConversionError, StoreError: Error> {

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
}

public extension DatabaseModel {

    /// Holds a CoreData field/attribute with custom validation and conversion logic
    typealias
        Field<FieldValue: DatabaseFieldValue, Value, OutputError: ConversionError, StoreError: Error>
        =
        FieldInterface<FieldValue, Value, Entity, OutputError, StoreError>
}

extension FieldInterface: FieldModifier where Entity: NSManagedObject {}
extension FieldInterface: FieldPublisher where Entity: NSManagedObject {}
extension FieldInterface: FieldInterfaceProtocol where Entity: NSManagedObject {}
