//
// CoreDataCandy
// Copyright © 2018-present Amaris Software.
// MIT license, see LICENSE file for details

import Combine

public extension DatabaseModel {

    func publisher<F: FieldPublisher>(for keyPath: KeyPath<Self, F>) -> AnyPublisher<F.Output, Never>
    where F.Entity == Entity {
        self[keyPath: keyPath].publisher(for: entity)
    }
}
