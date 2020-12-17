//
// CoreDataCandy
// Copyright © 2018-present Amaris Software.
// MIT license, see LICENSE file for details

import Foundation

private func preconditionFailureNoFallback(_ errorMessage: String) -> Never {
    preconditionFailure("\(errorMessage). No fallback value provided")
}

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

    /// - parameter fallback: If specified, this value will be used when it's not possible to decode the data as the given type rather than exiting with a `preconditionFailure`
    init<D: Codable>(_ keyPath: ReferenceWritableKeyPath<Entity, FieldValue>,
                     as: D.Type,
                     fallback fallbackValue: Value = nil,
                     validations: Validation<Value>...) where Value == D? {

        var conversionError: ConversionError?

        self.init(
            keyPath,
            outputConversion: { data in
                guard let data = data else { return nil }

                do {
                    let value = try JSONDecoder().decode(D.self, from: data)
                    return value
                } catch {
                    let errorMessage = "Error while decoding Data as \(Value.self). \(error.localizedDescription)"

                    if let fallback = fallbackValue {
                        conversionError = .decodingError(keyPath: keyPath, description: errorMessage)
                        return fallback
                    } else {
                        preconditionFailureNoFallback(errorMessage)
                    }
                }
            },
            storeConversion: { value in
                do {
                    let data = try JSONEncoder().encode(value)
                    return data
                } catch {
                    let errorMessage = "Error while encoding Data from \(Value.self). \(error.localizedDescription)"
                    conversionError = .decodingError(keyPath: keyPath, description: errorMessage)
                    return nil
                }
            },
            validations: validations
        )

        if let error = conversionError, let errorConversionObserved = self as? ConversionErrorObservable {
            errorConversionObserved.errorSubject.send(error)
        }
    }
}

// MARK: Data with default value

public extension FieldInterfaceProtocol where FieldValue == Data?, Value: Codable {

    /// - parameter fallback: If specified, this value will be used when it's not possible to decode the data as the given type rather than exiting with a `preconditionFailure`
    init(_ keyPath: ReferenceWritableKeyPath<Entity, FieldValue>,
         as: Value.Type,
         default defaultValue: Value,
         fallback fallbackValue: Value? = nil,
         validations: Validation<Value>...) {

        var conversionError: ConversionError?

        self.init(
            keyPath,
            outputConversion: { data in
                guard let data = data else { return defaultValue }

                do {
                    let value = try JSONDecoder().decode(Value.self, from: data)
                    return value
                } catch {

                    let errorMessage = "Error while decoding Data as \(Value.self). \(error.localizedDescription)"

                    if let fallback = fallbackValue {
                        conversionError = .decodingError(keyPath: keyPath, description: errorMessage)
                        return fallback
                    } else {
                        preconditionFailureNoFallback(errorMessage)
                    }
                }
            },
            storeConversion: { value in
                do {
                    let data = try JSONEncoder().encode(value)
                    return data
                } catch {
                    let errorMessage = "Error while encoding Data from \(Value.self). \(error.localizedDescription)"
                    conversionError = .decodingError(keyPath: keyPath, description: errorMessage)
                    return nil
                }
            },
            validations: validations
        )

        if let error = conversionError, let errorConversionObserved = self as? ConversionErrorObservable {
            errorConversionObserved.errorSubject.send(error)
        }
    }
}

// MARK: - Codable convertible

public extension FieldInterfaceProtocol where FieldValue == Data?, Value: ExpressibleByNilLiteral {

    /// - parameter fallback: If specified, this value will be used when it's not possible to decode the data as the given type rather than exiting with a `preconditionFailure`
    init<Convertible: CodableConvertible>(
        _ keyPath: ReferenceWritableKeyPath<Entity, FieldValue>,
        as: Convertible.Type,
        fallback fallbackValue: Convertible? = nil,
        validations: Validation<Value>...) where Value == Convertible? {

        var conversionError: ConversionError?

        self.init(
            keyPath,
            outputConversion: { data in
                guard let data = data else { return nil }

                do {
                    let value = try JSONDecoder().decode(Convertible.CodableModel.self, from: data)
                    return value.converted
                } catch {
                    let errorMessage = "Error while decoding Data as \(Value.self). \(error.localizedDescription)"

                    if let fallback = fallbackValue {
                        conversionError = .decodingError(keyPath: keyPath, description: errorMessage)
                        return fallback
                    } else {
                        preconditionFailureNoFallback(errorMessage)
                    }
                }
            },
            storeConversion: { value in
                guard let value = value else { return nil }
                do {
                    let data = try JSONEncoder().encode(value.codableModel)
                    return data
                } catch {
                    let errorMessage = "Error while encoding Data from \(Value.self). \(error.localizedDescription)"
                    conversionError = .decodingError(keyPath: keyPath, description: errorMessage)
                    return nil
                }
            },
            validations: validations
        )

        if let error = conversionError, let errorConversionObserved = self as? ConversionErrorObservable {
            errorConversionObserved.errorSubject.send(error)
        }
    }
}

// MARK: - RawRepresentable

public extension FieldInterfaceProtocol where FieldValue: ExpressibleByNilLiteral,
                                              Value: ExpressibleByNilLiteral {

    /// - parameter fallback: If specified, this value will be used when it's not possible to decode the data as the given type rather than exiting with a `preconditionFailure`
    init<R: RawRepresentable>(
        _ keyPath: ReferenceWritableKeyPath<Entity, FieldValue>,
        as: R.Type,
        fallback fallbackValue: Value = nil,
        validations: Validation<R>...) where Value == R?, FieldValue == R.RawValue? {

        var conversionError: ConversionError?

        self.init(
            keyPath,
            outputConversion: { rawValue in
                guard let rawValue = rawValue else { return nil }
                let errorMessage = "Instantiation of \(R.self) from the raw value \(rawValue) failed"

                if let value = R(rawValue: rawValue) {
                    return value
                } else if let fallback = fallbackValue {
                    conversionError = .rawRepresentable(keyPath: keyPath, description: errorMessage)
                    return fallback
                } else {
                    preconditionFailureNoFallback(errorMessage)
                }
            },
            storeConversion: { value in
                guard let value = value else { return nil }
                return value.rawValue
            },
            validations: validations
        )

        if let error = conversionError, let errorConversionObserved = self as? ConversionErrorObservable {
            errorConversionObserved.errorSubject.send(error)
        }
    }
}

public extension FieldInterfaceProtocol where Value: RawRepresentable,
                                              Value.RawValue == FieldValue {

    /// - parameter fallback: If specified, this value will be used when it's not possible to decode the data as the given type rather than exiting with a `preconditionFailure`
    init(
        _ keyPath: ReferenceWritableKeyPath<Entity, FieldValue>,
        as: Value.Type,
        fallback fallbackValue: Value? = nil,
        validations: Validation<Value>...) {

        var conversionError: ConversionError?

        self.init(
            keyPath,
            outputConversion: { rawValue in

                let errorMessage = "Instantiation of \(Value.self) from the raw value \(rawValue) failed"

                if let value = Value(rawValue: rawValue) {
                    return value
                } else if let fallback = fallbackValue {
                    conversionError = .rawRepresentable(keyPath: keyPath, description: errorMessage)
                    return fallback
                } else {
                    preconditionFailureNoFallback(errorMessage)
                }
            },
            storeConversion: { $0.rawValue },
            validations: validations
        )

        if let error = conversionError, let errorConversionObserved = self as? ConversionErrorObservable {
            errorConversionObserved.errorSubject.send(error)
        }
    }
}
