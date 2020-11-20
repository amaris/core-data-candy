//
// CoreDataCandy
// Copyright © 2018-present Amaris Software.
// MIT license, see LICENSE file for details

import Foundation

// MARK: - Identity

public extension FieldInterfaceProtocol where FieldValue == Value {

    init(_ keyPath: ReferenceWritableKeyPath<Entity, FieldValue>,
         validations: Validation<Value>...) {

        self.init(
            keyPath,
            outputConversion: { $0 },
            storeConversion: { $0 },
            validations: validations
        )
    }
}

// MARK: - ExpressibleByNilLiteral

public extension FieldInterfaceProtocol where FieldValue == Value,
                                              Value: ExpressibleByNilLiteral {

    init<U>(_ keyPath: ReferenceWritableKeyPath<Entity, FieldValue>,
            validations: Validation<U>...) where Value == U? {

        self.init(
            keyPath,
            outputConversion: { $0 },
            storeConversion: { $0 },
            validations: validations
        )
    }
}

public extension FieldInterfaceProtocol where FieldValue == Value? {

    init(_ keyPath: ReferenceWritableKeyPath<Entity, FieldValue>,
            default defaultValue: Value,
            validations: Validation<Value>...) {

        self.init(
            keyPath,
            outputConversion: { $0 ?? defaultValue },
            storeConversion: { $0 },
            validations: validations
        )
    }
}

// MARK: - Int

public extension FieldInterfaceProtocol where FieldValue == Int16, Value == Int {

    init(_ keyPath: ReferenceWritableKeyPath<Entity, FieldValue>,
         output: Value.Type = Int.self,
         validations: Validation<Value>...) {

        self.init(
            keyPath,
            outputConversion: { Int($0) },
            storeConversion: { Int16($0) },
            validations: validations
        )
    }
}

public extension FieldInterfaceProtocol where FieldValue == Int32, Value == Int {

    init(_ keyPath: ReferenceWritableKeyPath<Entity, FieldValue>,
         output: Value.Type = Int.self,
         validations: Validation<Value>...) {

        self.init(
            keyPath,
            outputConversion: { Int($0) },
            storeConversion: { Int32($0) },
            validations: validations
        )
    }
}

public extension FieldInterfaceProtocol where FieldValue == Int64, Value == Int {

    init(_ keyPath: ReferenceWritableKeyPath<Entity, FieldValue>,
         output: Value.Type = Int.self,
         validations: Validation<Value>...) {

        self.init(
            keyPath,
            outputConversion: { Int($0) },
            storeConversion: { Int64($0) },
            validations: validations
        )
    }
}

// MARK: - Data

public extension FieldInterfaceProtocol where FieldValue == Data?, Value: ExpressibleByNilLiteral {

    init<D: Codable>(_ keyPath: ReferenceWritableKeyPath<Entity, FieldValue>,
                     as: D.Type,
                     validations: Validation<Value>...) where Value == D? {

        self.init(
            keyPath,
            outputConversion: { data in
                guard let data = data else {
                    return nil
                }

                do {
                    let value = try JSONDecoder().decode(D.self, from: data)
                    return value
                } catch {
                    preconditionFailure("Error while decoding Data as \(Value.self). \(error.localizedDescription)")
                }
            },
            storeConversion: { value in
                do {
                    let data = try JSONEncoder().encode(value)
                    return data
                } catch {
                    preconditionFailure("Error while encoding \(Value.self) as Data. \(error.localizedDescription)")
                }
            },
            validations: validations
        )
    }
}

// MARK: Data with default value

public extension FieldInterfaceProtocol where FieldValue == Data?, Value: Codable {

    init(_ keyPath: ReferenceWritableKeyPath<Entity, FieldValue>,
                     as: Value.Type,
                     default defaultValue: Value,
                     validations: Validation<Value>...) {

        self.init(
            keyPath,
            outputConversion: { data in
                guard let data = data else {
                    return defaultValue
                }

                do {
                    let value = try JSONDecoder().decode(Value.self, from: data)
                    return value
                } catch {
                    preconditionFailure("Error while decoding Data as \(Value.self). \(error.localizedDescription)")
                }
            },
            storeConversion: { value in
                do {
                    let data = try JSONEncoder().encode(value)
                    return data
                } catch {
                    preconditionFailure("Error while encoding \(Value.self) as Data. \(error.localizedDescription)")
                }
            },
            validations: validations
        )
    }
}

// MARK: - Codable convertible

public extension FieldInterfaceProtocol where FieldValue == Data?, Value: ExpressibleByNilLiteral {

    init<Convertible: CodableConvertible>(
        _ keyPath: ReferenceWritableKeyPath<Entity, FieldValue>,
        as: Convertible.Type,
        validations: Validation<Value>...) where Value == Convertible? {

        self.init(
            keyPath,
            outputConversion: { data in
                guard let data = data else { return nil }

                do {
                    let value = try JSONDecoder().decode(Convertible.CodableModel.self, from: data)
                    return value.converted
                } catch {
                    preconditionFailure("Error while decoding Data as \(Value.self). \(error.localizedDescription)")
                }
            },
            storeConversion: { value in
                guard let value = value else { return nil }
                do {
                    let data = try JSONEncoder().encode(value.codableModel)
                    return data
                } catch {
                    preconditionFailure("Error while encoding \(Value.self) as Data. \(error.localizedDescription)")
                }
            },
            validations: validations
        )
    }
}
