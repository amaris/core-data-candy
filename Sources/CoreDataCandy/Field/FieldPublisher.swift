//
// Copyright © 2018-present Amaris Software.
//

import Combine

/// A field that can publish its value
public protocol FieldPublisher: class {
    associatedtype Value
    associatedtype OutputError: ConversionError

    var publisher: AnyPublisher<Value, OutputError> { get }

    func store(_ value: Value) throws
}
