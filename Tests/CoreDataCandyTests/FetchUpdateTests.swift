//
// CoreDataCandy
// Copyright © 2018-present Amaris Software.
// MIT license, see LICENSE file for details

import XCTest
import CoreData
import Combine
@testable import CoreDataCandy

final class FetchUpdateTests: XCTestCase {

    private var subscriptions = Set<AnyCancellable>()

    func testGetValues() {
        let expectedResults: [[StubEntity]] = [[.with(property: "Riri"), .with(property: "Fifi"), .with(property: "Loulou")],
                                               [.with(property: "Donald"), .with(property: "Daisy")]]

        var results = [[StubEntity]]()
        let fetchController = FetchResultsControllerMock()
        let stubController = NSFetchedResultsController<NSFetchRequestResult>()
        let publisher = Publishers.FetchUpdate<StubModel>(controller: fetchController)

        publisher
            .prefix(3)
            .sink { (_) in
                XCTAssertEqual(results.flatMap { $0.map(\.property) }, expectedResults.flatMap { $0.map(\.property) })
            } receiveValue: {
                results.append($0.map(\._entityWrapper.entity))
            }
            .store(in: &subscriptions)

        fetchController.mockObjects = expectedResults[0]
        fetchController.delegate?.controllerDidChangeContent?(stubController)
        fetchController.mockObjects = expectedResults[1]
        fetchController.delegate?.controllerDidChangeContent?(stubController)
    }
}

extension FetchUpdateTests {

    final class StubEntity: NSManagedObject, DatabaseEntity {

        static func fetchRequest() -> NSFetchRequest<StubEntity> {
            NSFetchRequest<StubEntity>(entityName: "Stub")
        }

        @objc var flag = false
        @objc var property = ""

        static func with(property: String) -> StubEntity {
            let entity = StubEntity()
            entity.property = property
            return entity
        }
    }

    struct StubModel: DatabaseModel {
        let _entityWrapper: EntityWrapper<StubEntity>

        let property = Field(\.property, validations: .doesNotContain("Yo"))
        let flag = Field(\.flag)

        init(entity: StubEntity) {
            _entityWrapper = EntityWrapper(entity: entity)
        }
    }

    final class FetchResultsControllerMock: NSFetchedResultsController<StubEntity> {
        var mockObjects = [StubEntity]()

        override var fetchedObjects: [StubEntity]? {
            mockObjects
        }
    }
}
