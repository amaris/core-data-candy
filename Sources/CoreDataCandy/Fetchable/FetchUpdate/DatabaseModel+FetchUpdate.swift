//
// Copyright © 2018-present Amaris Software.
//

import Combine
import CoreData

extension DatabaseModel where Entity: FetchableEntity {

    static func fetchController(context: NSManagedObjectContext, sorts: [SortDescriptor<Entity>]) -> NSFetchedResultsController<Entity> {
        let request = Entity.fetch
        request.sortDescriptors = sorts.map(\.descriptor)
        return NSFetchedResultsController(fetchRequest: request, managedObjectContext: context,
                                          sectionNameKeyPath: nil, cacheName: nil)
    }

    /// Publisher for the entity table updates in CoreData
    public static func updatePublisher(sortingBy sort: SortDescriptor<Entity>, in context: NSManagedObjectContext? = Self.context) -> AnyPublisher<[Self], Never> {
        guard let context = context else {
            assertionFailure("No context was provided to fetch the request. " +
                "Consider passing it as a parameter or changing the default 'nil' value of 'Fetchable.context'")
            return Just([Self]()).eraseToAnyPublisher()
        }

        let fetchController = Self.fetchController(context: context, sorts: [sort])

        return Publishers.fetchUpdate(for: Self.self, fetchController: fetchController)
            .eraseToAnyPublisher()
    }

    /// Publisher for the entity table updates in CoreData
    public static func updatePublisher(sortingBy sorts: [SortDescriptor<Entity>], in context: NSManagedObjectContext? = Self.context) -> AnyPublisher<[Self], Never> {
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
