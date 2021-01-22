//
// CoreDataCandy
// Copyright © 2018-present Amaris Software.
// MIT license, see LICENSE file for details

import CoreData
import Combine

/// Holds a CoreData field/attribute with custom validation and conversion logic
public struct FieldInterface<FieldValue: DatabaseFieldValue, Value, Entity: DatabaseEntity>: ConversionErrorObservable {

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
        self.validation = Validation<Value> { value in try validations.forEach { try $0.validate(value) }}
    }
}

public extension DatabaseModel {

    /// Holds a CoreData field/attribute with custom validation and conversion logic
    typealias
        Field<FieldValue: DatabaseFieldValue, Value>
        =
        FieldInterface<FieldValue, Value, Entity>
}

extension FieldInterface: FieldModifier where Entity: NSManagedObject {}
extension FieldInterface: FieldPublisher where Entity: NSManagedObject {}
extension FieldInterface: FieldInterfaceProtocol where Entity: NSManagedObject {}
