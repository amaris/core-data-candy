//
// Copyright © 2018-present Amaris Software.
//

import Foundation

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

    public func validate(_ value: Value) throws {
        try validation.validate(value)

        let storeConverted = storeConversion(value)
        let testValue: FieldValue

        switch storeConverted {
        case .success(let value): testValue = value
        case .failure(let error): throw error
        }

        if try Entity.fetch(.first(), where: keyPath == testValue) != nil {
            let field = keyPath.label.components(separatedBy: ".").last ?? ""
            throw CoreDataCandyError.existingUnique(field: field, value: String(describing: value), model: Entity.modelName)
        }
    }
}

public extension DatabaseModel where Entity: FetchableEntity {

    /// A field that has to be unique in the entity when compared to others
    typealias
        UniqueField<FieldValue: DatabaseFieldValue & Equatable, Value, OutputError: ConversionError, StoreError: Error>
        =
        UniqueFieldInterface<FieldValue, Value, Entity, OutputError, StoreError>
}
