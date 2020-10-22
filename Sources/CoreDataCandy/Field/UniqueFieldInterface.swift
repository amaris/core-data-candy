//
// Copyright © 2018-present Amaris Software.
//

import Foundation

public final class UniqueFieldInterface<FieldValue: DatabaseFieldValue & Equatable, Value, Entity: FetchableEntity, OutputError: ConversionError, StoreError: Error>:
    FieldInterface<FieldValue, Value, Entity, OutputError, StoreError> {

    override public func validate(_ value: Value) throws {
        try super.validate(value)
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
