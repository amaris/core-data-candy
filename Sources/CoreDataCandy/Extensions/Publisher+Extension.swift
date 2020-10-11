//
// Copyright © 2018-present Amaris Software.
//

import Combine

public extension Publisher {

    func unwrap<T>() -> Publishers.CompactMap<Self, T> where Output == Optional<T> {
        compactMap { $0 }
    }

    func tryAssign<Model: DatabaseModel, F: FieldPublisher>(to keyPath: KeyPath<Model, F>, on model: Model) -> AnyPublisher<Output, CoreDataCandyError>
    where F.Value == Output {

        return tryMap { value in
            try model.assign(value, to: keyPath)
            return value
        }
        .mapError { $0 as? CoreDataCandyError ?? .unknown }
        .eraseToAnyPublisher()
    }
}
