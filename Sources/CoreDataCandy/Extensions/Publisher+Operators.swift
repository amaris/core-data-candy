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
    where Output == Void, F.Value == Bool, F.Entity == Model.Entity, F.StoreConversionError == Never, Failure == Never {

        let subscriber = Subscribers.DatabaseModelToggle(keyPath: keyPath, model: model)
        self.subscribe(subscriber)
        return AnyCancellable(subscriber)
    }
}

extension Publisher where Output: Collection, Output.Element: DatabaseModel, Output.Element.Entity: FetchableEntity {

    /// Sort the children by the first criteria, then by the additional ones
    func sorted(by sort: Sort<Output.Element.Entity>, _ additionalSorts: Sort<Output.Element.Entity>...) -> AnyPublisher<[Output.Element], Failure> {
        map { $0.sorted(by: [sort] + additionalSorts) }.eraseToAnyPublisher()
    }

    /// Sort the children by the first criteria, then by the additional ones
    func sorted(by sorts: [Sort<Output.Element.Entity>]) -> AnyPublisher<[Output.Element], Failure> {
        map { $0.sorted(by: sorts) }.eraseToAnyPublisher()
    }
}

extension Subscribers {

    final class DatabaseModelAssign<Input, Model: DatabaseModel, F: FieldModifier>: Subscriber, Cancellable
    where F.Value == Input, F.Entity == Model.Entity {

        typealias Failure = Never

        let keyPath: KeyPath<Model, F>
        var model: Model?

        init(keyPath: KeyPath<Model, F>, model: Model) {
            self.keyPath = keyPath
            self.model = model
        }

        func receive(subscription: Subscription) {
            subscription.request(.unlimited)
        }

        func receive(_ input: Input) -> Subscribers.Demand {
            model?.assign(input, to: keyPath)
            return .unlimited
        }

        func receive(completion: Subscribers.Completion<Never>) {
            cancel()
        }

        func cancel() {
            model = nil
        }
    }

    final class DatabaseModelAssignWithError<Input, Model: DatabaseModel, F: FieldModifier>: Subscriber, Cancellable
    where F.Value == Input, F.Entity == Model.Entity {

        typealias Failure = CoreDataCandyError
        typealias CompletionHandler = (Completion<Failure>) -> Void

        let keyPath: KeyPath<Model, F>
        var model: Model?
        var receiveCompletion: CompletionHandler

        init(keyPath: KeyPath<Model, F>, model: Model, receiveCompletion: @escaping CompletionHandler) {
            self.keyPath = keyPath
            self.model = model
            self.receiveCompletion = receiveCompletion
        }

        func receive(subscription: Subscription) {
            subscription.request(.unlimited)
        }

        func receive(_ input: Input) -> Subscribers.Demand {
            model?.assign(input, to: keyPath)
            return .unlimited
        }

        func receive(completion: Subscribers.Completion<Failure>) {
            receiveCompletion(completion)
            cancel()
        }

        func cancel() {
            model = nil
        }
    }

    final class DatabaseModelToggle<Model: DatabaseModel, F: FieldInterfaceProtocol>: Subscriber, Cancellable
    where F.Value == Bool, F.Entity == Model.Entity, F.StoreConversionError == Never {
        typealias Input = Void
        typealias Failure = Never

        let keyPath: KeyPath<Model, F>
        var model: Model?

        init(keyPath: KeyPath<Model, F>, model: Model) {
            self.keyPath = keyPath
            self.model = model
        }

        func receive(subscription: Subscription) {
            subscription.request(.unlimited)
        }

        func receive(_ input: Input) -> Subscribers.Demand {
            model?.toggle(keyPath)
            return .unlimited
        }

        func receive(completion: Subscribers.Completion<Never>) {
            cancel()
        }

        func cancel() {
            model = nil
        }
    }
}
