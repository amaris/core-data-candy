//
// Copyright © 2018-present Amaris Software.
//

import CoreData
import Combine

extension Publishers {

    /// Tranforms a fetch controller delegate functions to a publisher
    struct FetchUpdate<Model: DatabaseModel>: Publisher where Model.Entity: FetchableEntity {

        typealias Output = [Model]
        typealias Failure = Never

        private let fetchController: NSFetchedResultsController<Model.Entity>

        init(controller: NSFetchedResultsController<Model.Entity>) {
            self.fetchController = controller
        }

        func receive<S>(subscriber: S) where S: Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
            let subscription = FetchUpdateSubscription(subscriber: subscriber, model: Model.self, fetchController: fetchController)
            subscriber.receive(subscription: subscription)
        }
    }

    static func fetchUpdate<Model>(for type: Model.Type, fetchController: NSFetchedResultsController<Model.Entity>) -> FetchUpdate<Model> {
        FetchUpdate<Model>(controller: fetchController)
    }
}

final class FetchUpdateSubscription<S: Subscriber, M: DatabaseModel>: NSObject, NSFetchedResultsControllerDelegate, Subscription
where S.Input == [M], M.Entity: FetchableEntity {

    var subscriber: S?
    var requested: Subscribers.Demand = .none
    private let fetchController: NSFetchedResultsController<M.Entity>

    func request(_ demand: Subscribers.Demand) {
        requested += demand
        guard requested > .none else {
            subscriber?.receive(completion: .finished)
            return
        }
        try? fetchController.performFetch()
        sendFetchedObjectsUpdate()
    }

    func cancel() {
        subscriber = nil
    }

    init(subscriber: S, model: M.Type, fetchController: NSFetchedResultsController<M.Entity>) {
        self.subscriber = subscriber
        self.fetchController = fetchController

        super.init()

        fetchController.delegate = self
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        sendFetchedObjectsUpdate()
    }

    private func sendFetchedObjectsUpdate() {
        guard
            let objects = fetchController.fetchedObjects,
            requested > .none
        else { return }

        requested -= .max(1)
        _ = subscriber?.receive(objects.map(M.init))
    }
}
