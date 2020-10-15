//
// Copyright © 2018-present Amaris Software.
//

import Foundation

// MARK: - Identity

public extension FieldWrapper where FieldValue == Value,
                                    OutputError == Never,
                                    StoreError == Never {

    init(_ keyPath: WritableKeyPath<Entity, FieldValue>,
         validations: Validation<Value>...) {

        self.init(
            keyPath,
            outputConversion: { .success($0) },
            storeConversion: { .success($0) },
            validations: validations
        )
    }
}

public extension FieldWrapper where FieldValue == Value,
                                    FieldValue: ExpressibleByNilLiteral,
                                    OutputError == Never,
                                    StoreError == Never {

    init<U>(_ keyPath: WritableKeyPath<Entity, FieldValue>,
            validations: Validation<U>...) where Value == U? {

        self.init(
            keyPath,
            outputConversion: { .success($0) },
            storeConversion: { .success($0) },
            validations: validations
        )
    }
}

// MARK: - Int

public extension FieldWrapper where FieldValue == Int16,
                                    Value == Int,
                                    OutputError == Never,
                                    StoreError == Never {

    init(_ keyPath: WritableKeyPath<Entity, FieldValue>,
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

public extension FieldWrapper where FieldValue == Int32,
                                    Value == Int,
                                    OutputError == Never,
                                    StoreError == Never {

    init(_ keyPath: WritableKeyPath<Entity, FieldValue>,
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

public extension FieldWrapper where FieldValue == Int64,
                                    Value == Int,
                                    OutputError == Never,
                                    StoreError == Never {

    init(_ keyPath: WritableKeyPath<Entity, FieldValue>,
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

// MARK: Default value

public extension FieldWrapper where FieldValue == Data,
                                    Value: DataConvertible,
                                    OutputError == Never,
                                    StoreError == CoreDataCandyError {

    init(_ keyPath: WritableKeyPath<Entity, FieldValue>,
                     output: Value.Type,
                     default defaultValue: Value,
                     validations: Validation<Value>...) {

        self.init(
            keyPath,
            outputConversion: {
                if let value = Value(data: $0) {
                    return .success(value)
                } else {
                    return .success(defaultValue)
                }
            },
            storeConversion: {
                if let data = $0.data {
                    return.success(data)
                } else {
                    return .failure(.outputConversion(keyPath: keyPath.label))
                }
            },
            validations: validations
        )
    }

    /// - parameter storeAs: Specify here a closure returning `Data` to save the value to the database with a different value than the default `data` one
    init(_ keyPath: WritableKeyPath<Entity, FieldValue>,
                     default defaultValue: Value,
                     storeAs storeFunction: @escaping ((Value) -> Data?),
                     validations: Validation<Value>...) {

        self.init(
            keyPath,
            outputConversion: {
                if let value = Value(data: $0) {
                    return .success(value)
                } else {
                    return .success(defaultValue)
                }
            },
            storeConversion: {
                if let data = storeFunction($0) {
                    return.success(data)
                } else {
                    return .failure(.outputConversion(keyPath: keyPath.label))
                }
            },
            validations: validations
        )
    }

    /// - parameter storeAs: Specify here a key path to a `Data` property to save the value to the database with a different value than the default `data` one
    init(_ keyPath: WritableKeyPath<Entity, FieldValue>,
                     storeAs storeKeyPath: KeyPath<Value, Data?>,
                     default defaultValue: Value,
                     validations: Validation<Value>...) {

        self.init(
            keyPath,
            outputConversion: {
                if let value = Value(data: $0) {
                    return .success(value)
                } else {
                    return .success(defaultValue)
                }
            },
            storeConversion: {
                if let data = $0[keyPath: storeKeyPath] {
                    return.success(data)
                } else {
                    return .failure(.outputConversion(keyPath: keyPath.label))
                }
            },
            validations: validations
        )
    }
}

// MARK: Error (no default)

public extension FieldWrapper where FieldValue == Data,
                                    Value: DataConvertible,
                                    OutputError == CoreDataCandyError,
                                    StoreError == CoreDataCandyError {

    init(_ keyPath: WritableKeyPath<Entity, FieldValue>,
                     output: Value.Type,
                     validations: Validation<Value>...) {
        self.init(
            keyPath,
            outputConversion: {
                if let value = Value(data: $0) {
                    return .success(value)
                } else {
                    return .failure(.outputConversion(keyPath: keyPath.label))
                }
            },
            storeConversion: {
                if let data = $0.data {
                    return.success(data)
                } else {
                    return .failure(.outputConversion(keyPath: keyPath.label))
                }
            },
            validations: validations
        )
    }

    /// - parameter storeAs: Specify here a closure returning `Data` to save the value to the database with a different value than the default `data` one
    init(_ keyPath: WritableKeyPath<Entity, FieldValue>,
                     storeAs storeFunction: @escaping ((Value) -> Data?),
                     validations: Validation<Value>...) {

        self.init(
            keyPath,
            outputConversion: {
                if let value = Value(data: $0) {
                    return .success(value)
                } else {
                    return .failure(.outputConversion(keyPath: keyPath.label))
                }
            },
            storeConversion: {
                if let data = storeFunction($0) {
                    return.success(data)
                } else {
                    return .failure(.storeConversion(keyPath: keyPath.label))
                }
            },
            validations: validations
        )
    }

    /// - parameter storeAs: Specify here a key path to a `Data` property to save the value to the database with a different value than the default `data` one
    init(_ keyPath: WritableKeyPath<Entity, FieldValue>,
                     storeAs storeKeyPath: KeyPath<Value, Data?>,
                     validations: Validation<Value>...) {

        self.init(
            keyPath,
            outputConversion: {
                if let value = Value(data: $0) {
                    return .success(value)
                } else {
                    return .failure(.outputConversion(keyPath: keyPath.label))
                }
            },
            storeConversion: {
                if let data = $0[keyPath: storeKeyPath] {
                    return.success(data)
                } else {
                    return .failure(.storeConversion(keyPath: keyPath.label))
                }
            },
            validations: validations
        )
    }
}

// MARK: Optional Data

// MARK: Error (no default)

public extension FieldWrapper where FieldValue == Data?,
                                    Value: ExpressibleByNilLiteral,
                                    OutputError == CoreDataCandyError,
                                    StoreError == CoreDataCandyError {

    init<D: DataConvertible>(_ keyPath: WritableKeyPath<Entity, FieldValue>,
                                         output: Value.Type,
                                         validations: Validation<Value>...) where Value == D? {

        self.init(
            keyPath,
            outputConversion: { data in
                guard let data = data else {
                    return .success(nil)
                }
                guard let value = D(data: data) else {
                    return .failure(.outputConversion(keyPath: keyPath.label))
                }
                return .success(value)
            },
            storeConversion: { value in
                guard let data = value?.data else {
                    return .failure(.storeConversion(keyPath: keyPath.label))
                }
                return .success(data)
            },
            validations: validations
        )
    }

    /// - parameter storeAs: Specify here a closure returning `Data` to save the value to the database with a different value than the default `data` one
    init<D: DataConvertible>(_ keyPath: WritableKeyPath<Entity, FieldValue>,
                                         output: Value.Type,
                                         storeAs storeFunction: @escaping ((D) -> Data?),
                                         validations: Validation<Value>...) where Value == D? {

        self.init(
            keyPath,
            outputConversion: { data in
                guard let data = data else {
                    return .success(nil)
                }
                guard let value = D(data: data) else {
                    return .failure(.outputConversion(keyPath: keyPath.label))
                }
                return .success(value)
            },
            storeConversion: { value in
                guard let value = value else {
                    return .success(nil)
                }
                guard let data = storeFunction(value) else {
                    return .failure(.storeConversion(keyPath: keyPath.label))
                }
                return .success(data)
            },
            validations: validations
        )
    }

    /// - parameter storeAs: Specify here a key path to a `Data` property to save the value to the database with a different value than the default `data` one
    init<D: DataConvertible>(_ keyPath: WritableKeyPath<Entity, FieldValue>,
                                         output: Value.Type,
                                         storeAs storeKeyPath: KeyPath<D, Data?>,
                                         validations: Validation<Value>...) where Value == D? {

        self.init(
            keyPath,
            outputConversion: { data in
                guard let data = data else {
                    return .success(nil)
                }
                guard let value = D(data: data) else {
                    return .failure(.outputConversion(keyPath: keyPath.label))
                }
                return .success(value)
            },
            storeConversion: { value in
                guard let value = value else {
                    return .success(nil)
                }
                guard let data = value[keyPath: storeKeyPath] else {
                    return .failure(.storeConversion(keyPath: keyPath.label))
                }
                return .success(data)
            },
            validations: validations
        )
    }
}

// MARK: - NSObject

// MARK: Default

extension FieldWrapper where FieldValue == NSObject,
                             Value: NSObject,
                             OutputError == Never,
                             StoreError == Never {

    init(_ keyPath: WritableKeyPath<Entity, FieldValue>,
                     output: Value.Type,
                     default defaultValue: Value,
                     validations: Validation<Value>...) {

        self.init(
            keyPath,
            outputConversion: { .success($0 as? Value ?? defaultValue) },
            storeConversion: { .success($0) },
            validations: validations
        )
    }
}

// MARK: Error (no default)

public extension FieldWrapper where FieldValue == NSObject,
                                    Value: NSObject,
                                    OutputError == CoreDataCandyError,
                                    StoreError == Never {

    init(_ keyPath: WritableKeyPath<Entity, FieldValue>,
                     output: Value.Type,
                     validations: Validation<Value>...) {

        self.init(
            keyPath,
            outputConversion: {
                guard let outputValue = $0 as? Value else {
                    return .failure(.outputConversion(keyPath: keyPath.label))
                }

                return .success(outputValue)
            },
            storeConversion: { .success($0) },
            validations: validations
        )
    }
}

// MARK: Optional NSOject

public extension FieldWrapper where FieldValue == NSObject?,
                             Value: ExpressibleByNilLiteral,
                             OutputError == CoreDataCandyError,
                             StoreError == Never {

    init<O: NSObject>(_ keyPath: WritableKeyPath<Entity, FieldValue>,
                                  output: Value.Type,
                                  validations: Validation<Value>...) where Value == O? {

        self.init(
            keyPath,
            outputConversion: { object in
                if let object = object as? Value {
                    return .success(object)
                } else {
                    return .failure(.outputConversion(keyPath: keyPath.label))
                }
            },
            storeConversion: { .success($0) },
            validations: validations
        )
    }
}
