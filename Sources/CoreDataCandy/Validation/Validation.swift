//
// Copyright © 2018-present Amaris Software.
//

/// Specified in a `FieldWrapper` initialisation to validate the received value
public struct Validation<Value> {
    public var validate: (Value) throws -> Void
}
