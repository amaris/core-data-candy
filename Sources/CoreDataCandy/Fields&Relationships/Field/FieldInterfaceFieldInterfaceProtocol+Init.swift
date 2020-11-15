//
// Copyright © 2018-present Amaris Software.
//

import Foundation

// MARK: - Identity

public extension FieldInterfaceProtocol where FieldValue == Value,
                                              StoreConversionError == Never {

    init(_ keyPath: ReferenceWritableKeyPath<Entity, FieldValue>,
         validations: Validation<Value>...) {

        self.init(
            keyPath,
            outputConversion: { .success($0) },
            storeConversion: { .success($0) },
            validations: validations
        )
    }
}

// MARK: - ExpressibleByNilLiteral

public extension FieldInterfaceProtocol where FieldValue == Value,
                                              Value: ExpressibleByNilLiteral,
                                              StoreConversionError == Never {

    init<U>(_ keyPath: ReferenceWritableKeyPath<Entity, FieldValue>,
            validations: Validation<U>...) where Value == U? {

        self.init(
            keyPath,
            outputConversion: { .success($0) },
            storeConversion: { .success($0) },
            validations: validations
        )
    }
}

public extension FieldInterfaceProtocol where FieldValue == Value?,
                                              StoreConversionError == Never {

    init(_ keyPath: ReferenceWritableKeyPath<Entity, FieldValue>,
            default defaultValue: Value,
            validations: Validation<Value>...) {

        self.init(
            keyPath,
            outputConversion: { .success($0 ?? defaultValue) },
            storeConversion: { .success($0) },
            validations: validations
        )
    }
}

// MARK: - Int

public extension FieldInterfaceProtocol where FieldValue == Int16,
                                              Value == Int,
                                              StoreConversionError == Never {

    init(_ keyPath: ReferenceWritableKeyPath<Entity, FieldValue>,
         output: Value.Type = Int.self,
         validations: Validation<Value>...) {

        self.init(
            keyPath,
            outputConversion: { .success(Int($0)) },
            storeConversion: { .success(Int16($0)) },
            validations: validations
        )
    }
}

public extension FieldInterfaceProtocol where FieldValue == Int32,
                                              Value == Int,
                                              StoreConversionError == Never {

    init(_ keyPath: ReferenceWritableKeyPath<Entity, FieldValue>,
         output: Value.Type = Int.self,
         validations: Validation<Value>...) {

        self.init(
            keyPath,
            outputConversion: { .success(Int($0)) },
            storeConversion: { .success(Int32($0)) },
            validations: validations
        )
    }
}

public extension FieldInterfaceProtocol where FieldValue == Int64,
                                              Value == Int,
                                              StoreConversionError == Never {

    init(_ keyPath: ReferenceWritableKeyPath<Entity, FieldValue>,
         output: Value.Type = Int.self,
         validations: Validation<Value>...) {

        self.init(
            keyPath,
            outputConversion: { .success(Int($0)) },
            storeConversion: { .success(Int64($0)) },
            validations: validations
        )
    }
}

// MARK: - Data

public extension FieldInterfaceProtocol where FieldValue == Data?,
                                              Value: ExpressibleByNilLiteral,
                                              StoreConversionError == CoreDataCandyError {

    init<D: Codable>(_ keyPath: ReferenceWritableKeyPath<Entity, FieldValue>,
                     as: D.Type,
                     validations: Validation<Value>...) where Value == D? {

        self.init(
            keyPath,
            outputConversion: { data in
                guard let data = data else {
                    return .success(nil)
                }

                do {
                    let value = try JSONDecoder().decode(D.self, from: data)
                    return .success(value)
                } catch {
                    preconditionFailure("Error while converting \(FieldValue.self) as \(Value.self). \(error.localizedDescription)")
                }
            },
            storeConversion: { value in
                do {
                    let data = try JSONEncoder().encode(value)
                    return .success(data)
                } catch {
                    preconditionFailure(error.localizedDescription)
                }
            },
            validations: validations
        )
    }
}

public extension FieldInterfaceProtocol where FieldValue == Data?,
                                              Value: Codable,
                                              StoreConversionError == Never {

    init(_ keyPath: ReferenceWritableKeyPath<Entity, FieldValue>,
                     as: Value.Type,
                     default defaultValue: Value,
                     validations: Validation<Value>...) {

        self.init(
            keyPath,
            outputConversion: { data in
                guard let data = data else {
                    return .success(defaultValue)
                }

                do {
                    let value = try JSONDecoder().decode(Value.self, from: data)
                    return .success(value)
                } catch {
                    preconditionFailure("Error while converting \(FieldValue.self) as \(Value.self). \(error.localizedDescription)")
                }
            },
            storeConversion: { value in
                do {
                    let data = try JSONEncoder().encode(value)
                    return .success(data)
                } catch {
                    fatalError("A 'Never' error has been thrown")
                }
            },
            validations: validations
        )
    }
}
