//
// CoreDataCandy
// Copyright © 2018-present Amaris Software.
// MIT license, see LICENSE file for details

import Foundation
import Combine
import CoreData

/// A field interface that emits conversion errors
protocol ConversionErrorObservable {

    var errorSubject: PassthroughSubject<ConversionError, Never> { get }
}

/// Emitted through a publisher when a conversion from stored <-> output value failed
public struct ConversionError: LocalizedError {

    /// The entity attribute label
    public var attributeLabel: String
    public var errorDescription: String?

    public init(attributeLabel: String, description: String) {
        self.attributeLabel = attributeLabel
        errorDescription = description
    }
}

public extension ConversionError {

    static func decodingError<E: NSManagedObject, Value>(keyPath: KeyPath<E, Value>, description: String) -> ConversionError {
        ConversionError(attributeLabel: keyPath.label,
                        description: "Decoding error. \(description)")
    }

    static func rawRepresentable<E: NSManagedObject, Value>(keyPath: KeyPath<E, Value>, description: String) -> ConversionError {
        ConversionError(attributeLabel: keyPath.label,
                        description: "Raw representable init error. \(description)")
    }
}
