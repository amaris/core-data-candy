//
// Copyright © 2018-present Amaris Software.
//

import Combine
import CoreData

/// A field that can publish its value (in front of a CoreData entity attribute)
public protocol FieldPublisher {
    associatedtype Entity: DatabaseEntity
    associatedtype Output
    associatedtype StoreConversionError: ConversionError

    /// A publisher for the given entity property with an ouput conversion
    func publisher(for entity: Entity) -> AnyPublisher<Output, Never>
}
