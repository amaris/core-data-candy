//
// Copyright © 2018-present Amaris Software.
//

import Combine
import CoreData

extension DatabaseModel {

    private static func fetchController(context: NSManagedObjectContext, sorts: [Sort<Entity>]) -> NSFetchedResultsController<Entity> {
        let request = Entity.fetch
        request.sortDescriptors = sorts.map { $0.descriptor }
        return NSFetchedResultsController(fetchRequest: request, managedObjectContext: context,
                                                     sectionNameKeyPath: nil, cacheName: nil)
    }

    public static func updatePublisher(sortingBy sort: Sort<Entity>, in context: NSManagedObjectContext?  = Self.context) -> AnyPublisher<[Self], Never> {
        guard let context = context else {
            assertionFailure("No context was provided to fetch the request. " +
                "Consider passing it as a parameter or changing the default 'nil' value of 'Fetchable.context'")
            return Just([Self]()).eraseToAnyPublisher()
        }

        let fetchController = Self.fetchController(context: context, sorts: [sort])
        return Publishers.fetchUpdate(for: Self.self, fetchController: fetchController)
            .eraseToAnyPublisher()
    }

    public static func updatePublisher(sortingBy sorts: [Sort<Entity>], in context: NSManagedObjectContext?  = Self.context) -> AnyPublisher<[Self], Never> {
        guard let context = context else {
            assertionFailure("No context was provided to fetch the request. " +
                             "Consider passing it as a parameter or changing the default 'nil' value of 'Fetchable.context'")
            return Just([Self]()).eraseToAnyPublisher()
        }

        let fetchController = Self.fetchController(context: context, sorts: sorts)
        return Publishers.fetchUpdate(for: Self.self, fetchController: fetchController)
            .eraseToAnyPublisher()
    }
}
