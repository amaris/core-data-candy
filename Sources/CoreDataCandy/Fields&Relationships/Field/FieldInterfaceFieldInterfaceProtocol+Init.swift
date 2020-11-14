//
// Copyright © 2018-present Amaris Software.
//

import Foundation

// MARK: - Identity

public extension FieldInterfaceProtocol where FieldValue == Value,
                                              OutputError == Never,
                                              StoreError == Never {

    init(_ keyPath: ReferenceWritableKeyPath<Entity, FieldValue>,
         validations: Validation<Value>...) {

        self.init(
            keyPath,
            defaultValue: nil,
            outputConversion: { .success($0) },
            storeConversion: { .success($0) },
            validations: validations
        )
    }
}

// MARK: - ExpressibleByNilLiteral

public extension FieldInterfaceProtocol where FieldValue == Value,
                                              Value: ExpressibleByNilLiteral,
                                              OutputError == Never,
                                              StoreError == Never {

    init<U>(_ keyPath: ReferenceWritableKeyPath<Entity, FieldValue>,
            validations: Validation<U>...) where Value == U? {

        self.init(
            keyPath,
            defaultValue: nil,
            outputConversion: { .success($0) },
            storeConversion: { .success($0) },
            validations: validations
        )
    }
}

public extension FieldInterfaceProtocol where FieldValue == Value?,
                                              OutputError == CoreDataCandyError,
                                              StoreError == Never {

    /// Try to unwrap the optional field value when publishing
    init(unwrapped keyPath: ReferenceWritableKeyPath<Entity, FieldValue>,
         validations: Validation<Value>...) {

        self.init(
            keyPath,
            defaultValue: nil,
            outputConversion: { fieldValue in
                guard let value = fieldValue else {
                    return .failure(.outputConversion)
                }
                return .success(value)
            },
            storeConversion: { .success($0) },
            validations: validations
        )
    }
}

// MARK: - Int

public extension FieldInterfaceProtocol where FieldValue == Int16,
                                              Value == Int,
                                              OutputError == Never,
                                              StoreError == Never {

    init(_ keyPath: ReferenceWritableKeyPath<Entity, FieldValue>,
         output: Value.Type = Int.self,
         validations: Validation<Value>...) {

        self.init(
            keyPath,
            defaultValue: nil,
            outputConversion: { .success(Int($0)) },
            storeConversion: { .success(Int16($0)) },
            validations: validations
        )
    }
}

public extension FieldInterfaceProtocol where FieldValue == Int32,
                                              Value == Int,
                                              OutputError == Never,
                                              StoreError == Never {

    init(_ keyPath: ReferenceWritableKeyPath<Entity, FieldValue>,
         output: Value.Type = Int.self,
         validations: Validation<Value>...) {

        self.init(
            keyPath,
            defaultValue: nil,
            outputConversion: { .success(Int($0)) },
            storeConversion: { .success(Int32($0)) },
            validations: validations
        )
    }
}

public extension FieldInterfaceProtocol where FieldValue == Int64,
                                              Value == Int,
                                              OutputError == Never,
                                              StoreError == Never {

    init(_ keyPath: ReferenceWritableKeyPath<Entity, FieldValue>,
         output: Value.Type = Int.self,
         validations: Validation<Value>...) {

        self.init(
            keyPath,
            defaultValue: nil,
            outputConversion: { .success(Int($0)) },
            storeConversion: { .success(Int64($0)) },
            validations: validations
        )
    }
}

// MARK: - Data

public extension FieldInterfaceProtocol where FieldValue == Data?,
                                              Value: ExpressibleByNilLiteral,
                                              OutputError == CoreDataCandyError,
                                              StoreError == CoreDataCandyError {

    init<D: Codable>(_ keyPath: ReferenceWritableKeyPath<Entity, FieldValue>,
                     as: D.Type,
                     validations: Validation<Value>...) where Value == D? {

        self.init(
            keyPath,
            defaultValue: nil,
            outputConversion: { data in
                guard let data = data else {
                    return .success(nil)
                }

                do {
                    let value = try JSONDecoder().decode(D.self, from: data)
                    return .success(value)
                } catch {
                    return .failure(.outputConversion)
                }
            },
            storeConversion: { value in
                do {
                    let data = try JSONEncoder().encode(value)
                    return .success(data)
                } catch {
                    return .failure(.storeConversion)
                }
            },
            validations: validations
        )
    }
}
