//
// Copyright © 2018-present Amaris Software.
//

import XCTest
import Combine
import CoreData
import CoreDataCandy

final class DatabaseModelTests: XCTestCase {

    private var subscriptions = Set<AnyCancellable>()

    override func setUp() {
        subscriptions = []
    }

    func testAssign() throws {
        let model = StubModel()

        try model.assign("Hello", to: \.property)

        XCTAssertEqual(model.entity.property, "Hello")
    }

    func testValidateAssign_ValidateWrongValueThrows() throws {
        let model = StubModel()

        XCTAssertThrowsError(try model.assign("Yo", to: \.property))
    }

    func testValidateAssignWithPublisher() throws {
        let model = StubModel()

        Just("Hello")
            .tryAssign(to: \.property, on: model)
            .sink { _ in  }
                receiveValue: { (_) in XCTAssertEqual(model.entity.property, "Hello") }
            .store(in: &subscriptions)
    }

    func testValidateAssignWithPublisher_ValidateWrongValueThrows() throws {
        let model = StubModel()

        Just("Yo")
            .tryAssign(to: \.property, on: model)
            .sink { completion in
                guard case .failure = completion else {
                    XCTFail()
                    return
                }
            } receiveValue: { (_) in }
            .store(in: &subscriptions)
    }

    func test() throws {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        let ent = try StubEntity.fetch(.all(), where: \.age == 25, in: context)
        print(ent)
    }
}

extension DatabaseModelTests {

    final class StubEntity: NSManagedObject, FetchableEntity {
        static func fetchRequest() -> NSFetchRequest<StubEntity> {
            NSFetchRequest<StubEntity>(entityName: "Stub")
        }

        let id = UUID()
        var age: Int?
        @objc var property = ""
    }

    final class StubModel: DatabaseModel {
        var entity = StubEntity()

        let property = Field(\.property, validations: .doesNotContain("Yo"))
        let age = Field(\.age)

        init(entity: StubEntity) {}

        init() {}
    }
}
