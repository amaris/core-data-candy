//
// CoreDataCandy
// Copyright © 2018-present Amaris Software.
// MIT license, see LICENSE file for details

/// Specified in a `FieldWrapper` initialisation to validate the received value
public struct Validation<Value> {
    public var validate: (Value) throws -> Void

    public init(_ validate: @escaping (Value) throws -> Void) {
        self.validate = validate
    }
}
