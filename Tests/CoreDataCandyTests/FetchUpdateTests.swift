//
// Copyright © 2018-present Amaris Software.
//

import XCTest
import Combine
@testable import CoreDataCandy

final class FetchUpdateTests: XCTestCase {

    private var subscriptions = Set<AnyCancellable>()

    func testGetValues() {
//        let expectedResults = [[StubEntity(property: "Riri"), StubEntity(property: "Fifi"), StubEntity(property: "Loulou")],
//                               [StubEntity(property: "Donald"), StubEntity(property: "Daisy")]]

        var results = [[StubEntity]]()
        let fetchController = FetchResultsControllerMock()
        let stubController = NSFetchedResultsController<NSFetchRequestResult>()
        let publisher = Publishers.FetchUpdate<StubModel>(controller: fetchController)
        var count = 0

        publisher
            .print("Fetch")
            .sink { (completion) in
            } receiveValue: {
                count += 1
                results.append($0.map(\.entity))
                if count == 3 {
//                    XCTAssertEqual(results, expectedResults)
                }
            }
            .store(in: &subscriptions)

//        fetchController.mockObjects = expectedResults[0]
//        fetchController.delegate?.controllerDidChangeContent?(stubController)
//        fetchController.mockObjects = expectedResults[1]
//        fetchController.delegate?.controllerDidChangeContent?(stubController)
    }
}

extension FetchUpdateTests {

    final class StubEntity: NSManagedObject, FetchableEntity {


        static var modelName = "SutbEntity"

        static func fetchRequest() -> NSFetchRequest<StubEntity> {
            NSFetchRequest<StubEntity>(entityName: "Stub")
        }

        @objc var flag = false
        @objc var property = ""
    }

    struct StubModel: DatabaseModel {
        var entity = StubEntity()

        let property = Field(\.property, validations: .doesNotContain("Yo"))
        let flag = Field(\.flag)

        init(entity: StubEntity) {}

        init() {}
    }

    final class FetchResultsControllerMock: NSFetchedResultsController<StubEntity> {
        var mockObjects = [StubEntity]()

        override var fetchedObjects: [FetchUpdateTests.StubEntity]? {
            mockObjects
        }
    }
}
