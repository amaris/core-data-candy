//
// Copyright © 2018-present Amaris Software.
//

import Combine
import CoreData

/// A field that can publish its value
public protocol FieldPublisher {
    associatedtype Entity: NSManagedObject
    associatedtype Value
    associatedtype OutputError: ConversionError

    /// A publisher for the given entity property with an ouput conversion
    func publisher(for entity: Entity) -> AnyPublisher<Value, OutputError>

    /// Store the value in the entity after validating it
    func set(_ value: Value, on entity: Entity) throws

    /// Try to get the current stored value in the entity
    func currentValue(in entity: Entity) throws -> Value

    func validate(_ value: Value) throws
}

public extension FieldPublisher where Value == Bool {

    func toggle(on entity: Entity) throws {
        let flag = try currentValue(in: entity)
        try set(!flag, on: entity)
    }
}
