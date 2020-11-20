//
// CoreDataCandy
// Copyright © 2018-present Amaris Software.
// MIT license, see LICENSE file for details

import Combine

public extension DatabaseModel {

    /// Publisher for the given field
    func publisher<Value, F: FieldPublisher>(for keyPath: KeyPath<Self, F>) -> AnyPublisher<Value, Never>
    where Value == F.Output, F.Entity == Entity {
        self[keyPath: keyPath].publisher(for: entity)
    }
}
