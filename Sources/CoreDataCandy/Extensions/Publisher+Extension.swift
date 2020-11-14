//
// Copyright © 2018-present Amaris Software.
//

import Combine

public extension Publisher {

    func unwrap<T>() -> Publishers.CompactMap<Self, T> where Output == T? {
        compactMap { $0 }
    }

    /// Try to assign the value to the given field, returning a publisher with an error if the value is not validated or if the context cannot be saved
    func tryAssign<Model: DatabaseModel, F: FieldModifier>(to keyPath: KeyPath<Model, F>, on model: Model) -> AnyPublisher<Output, CoreDataCandyError>
    where F.Value == Output, F.Entity == Model.Entity {

        return tryMap { value in
            try model.assign(value, to: keyPath)
            return value
        }
        .mapError { $0 as? CoreDataCandyError ?? .unknown }
        .eraseToAnyPublisher()
    }

    /// Try to toggle the boolean at the given field, returning a publisher with an error if the value is not validated or if the context cannot be saved
    func tryToggle<Model: DatabaseModel, F: FieldInterfaceProtocol>(_ keyPath: KeyPath<Model, F>, on model: Model) -> AnyPublisher<Void, CoreDataCandyError>
    where F.Value == Bool, F.Entity == Model.Entity, F.OutputError == Never {

        return tryMap { _ in
            try model.toggle(keyPath)
        }
        .mapError { $0 as? CoreDataCandyError ?? .unknown }
        .eraseToAnyPublisher()
    }
}

public extension Publisher where Output: Collection, Output.Element: DatabaseModel, Output.Element.Entity: FetchableEntity {

    func sorted<Value>(with sort: Sort<Output.Element.Entity, Value>) -> AnyPublisher<[Output.Element], Failure> {
        map { $0.sorted(with: sort) }.eraseToAnyPublisher()
    }
}
