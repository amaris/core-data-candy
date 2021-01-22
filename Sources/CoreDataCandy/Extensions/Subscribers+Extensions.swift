//
// CoreDataCandy
// Copyright © 2018-present Amaris Software.
// MIT license, see LICENSE file for details

import Combine

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
    where F.Value == Bool, F.Entity == Model.Entity {
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

