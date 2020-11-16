//
// Copyright © 2018-present Amaris Software.
//

import Combine

public extension Publisher {

    func unwrap<T>() -> Publishers.CompactMap<Self, T> where Output == T? {
        compactMap { $0 }
    }

    /// Try to validate the value to the given field
    func tryValidate<Model: DatabaseModel, F: FieldModifier>(for keyPath: KeyPath<Model, F>, on model: Model) -> AnyPublisher<Output, CoreDataCandyError>
    where F.Value == Output, F.Entity == Model.Entity {

        return tryMap { value in
            try model.validate(value, for: keyPath)
            return value
        }
        .mapError { $0 as? CoreDataCandyError ?? .unknown }
        .eraseToAnyPublisher()
    }

    /// Try to validate then assign the value to the given field, returning a publisher with an error if the value is not validated
    func tryValidateAndAssign<Model: DatabaseModel, F: FieldModifier>(to keyPath: KeyPath<Model, F>, on model: Model) -> AnyPublisher<Output, CoreDataCandyError>
    where F.Value == Output, F.Entity == Model.Entity {

        return tryMap { value in
            try model.validateAndAssign(value, to: keyPath)
            return value
        }
        .mapError { $0 as? CoreDataCandyError ?? .unknown }
        .eraseToAnyPublisher()
    }

    /// Assign the value to the field of the model
    func assign<Model: DatabaseModel, F: FieldModifier>(to keyPath: KeyPath<Model, F>, on model: Model) -> AnyPublisher<Output, Never>
    where F.Value == Output, F.Entity == Model.Entity, Failure == Never {

        return map { value in
            model.assign(value, to: keyPath)
            return value
        }
        .eraseToAnyPublisher()
    }

    /// Toggle the boolean at the given field
    func toggle<Model: DatabaseModel, F: FieldInterfaceProtocol>(_ keyPath: KeyPath<Model, F>, on model: Model) -> AnyPublisher<Void, Never>
    where F.Value == Bool, F.Entity == Model.Entity, F.StoreConversionError == Never, Failure == Never {

        return map { _ in
            model.toggle(keyPath)
        }
        .eraseToAnyPublisher()
    }
}

public extension Publisher where Output: Collection, Output.Element: DatabaseModel, Output.Element.Entity: FetchableEntity {

    func sorted<Value>(with sort: Sort<Output.Element.Entity, Value>) -> AnyPublisher<[Output.Element], Failure> {
        map { $0.sorted(with: sort) }.eraseToAnyPublisher()
    }
}
