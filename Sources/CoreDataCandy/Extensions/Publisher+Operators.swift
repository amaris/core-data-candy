//
// CoreDataCandy
// Copyright © 2018-present Amaris Software.
// MIT license, see LICENSE file for details

import Combine

public extension Publisher {

    func unwrap<T>() -> Publishers.CompactMap<Self, T> where Output == T? {
        compactMap { $0 }
    }

    /// Try to validate the value for the given field
    func tryValidate<Model: DatabaseModel, F: FieldModifier>(for keyPath: KeyPath<Model, F>, on model: Model) -> AnyPublisher<Output, CoreDataCandyError>
    where F.Value == Output, F.Entity == Model.Entity {

        return tryMap { value in
            try model.validate(value, for: keyPath)
            return value
        }
        .mapError { $0 as? CoreDataCandyError ?? .unknown }
        .eraseToAnyPublisher()
    }

    /// Assign the value to the field of the model, with a possibility to handle the validation error
    func assign<Model: DatabaseModel, F: FieldModifier>(
        to keyPath: KeyPath<Model, F>,
        on model: Model,
        receiveCompletion: @escaping (Subscribers.Completion<CoreDataCandyError>) -> Void)
    -> AnyCancellable
    where F.Value == Output, F.Entity == Model.Entity, Failure == CoreDataCandyError {
        let subscriber = Subscribers.DatabaseModelAssignWithError(keyPath: keyPath, model: model, receiveCompletion: receiveCompletion)
        self.subscribe(subscriber)
        return AnyCancellable(subscriber)
    }

    /// Assign the value to the field of the model
    func assign<Model: DatabaseModel, F: FieldModifier>(to keyPath: KeyPath<Model, F>, on model: Model) -> AnyCancellable
    where F.Value == Output, F.Entity == Model.Entity, Failure == Never {

        let subscriber = Subscribers.DatabaseModelAssign(keyPath: keyPath, model: model)
        self.subscribe(subscriber)
        return AnyCancellable(subscriber)
    }

    /// Toggle the boolean at the given field
    func toggle<Model: DatabaseModel, F: FieldInterfaceProtocol>(_ keyPath: KeyPath<Model, F>, on model: Model) -> AnyCancellable
    where Output == Void, F.Value == Bool, F.Entity == Model.Entity, Failure == Never {

        let subscriber = Subscribers.DatabaseModelToggle(keyPath: keyPath, model: model)
        self.subscribe(subscriber)
        return AnyCancellable(subscriber)
    }
}

extension Publisher where Output: Collection, Output.Element: DatabaseModel {

    /// Sort the children by the first criteria, then by the additional ones
    func sorted(by sort: Sort<Output.Element.Entity>, _ additionalSorts: Sort<Output.Element.Entity>...) -> AnyPublisher<[Output.Element], Failure> {
        map { $0.sorted(by: [sort] + additionalSorts) }.eraseToAnyPublisher()
    }

    /// Sort the children by the first criteria, then by the additional ones
    func sorted(by sorts: [Sort<Output.Element.Entity>]) -> AnyPublisher<[Output.Element], Failure> {
        map { $0.sorted(by: sorts) }.eraseToAnyPublisher()
    }
}
