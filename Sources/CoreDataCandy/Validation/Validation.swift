//
// Copyright © 2018-present Amaris Software.
//

/// Specify in a `FieldWrapper` initialisation to validate the recevied value
public struct Validation<Value> {
    public var validate: (Value) throws -> Void
}

