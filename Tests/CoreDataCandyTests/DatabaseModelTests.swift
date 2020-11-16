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

        model.assign("Hello", to: \.property)

        XCTAssertEqual(model.current(\.property), "Hello")
    }

    func testValidate_ValidateWrongValueThrows() throws {
        let model = StubModel()

        XCTAssertThrowsError(try model.validate("Yo", for: \.property))
    }

    func testToggle() throws {
        let model = StubModel()

        model.toggle(\.flag)

        XCTAssertEqual(model.current(\.flag), true)
    }

    func testValidateAndAssignWithPublisher() throws {
        let model = StubModel()

        Just("Hello")
            .tryValidateAndAssign(to: \.property, on: model)
            .sink { _ in  }
                receiveValue: { (_) in XCTAssertEqual(model.current(\.property), "Hello") }
            .store(in: &subscriptions)
    }

    func testValidateAssignWithPublisher_ValidateWrongValueThrows() throws {
        let model = StubModel()

        Just("Yo")
            .tryValidateAndAssign(to: \.property, on: model)
            .sink { completion in
                guard case .failure = completion else {
                    XCTFail()
                    return
                }
            } receiveValue: { (_) in }
            .store(in: &subscriptions)
    }

    func testPublisherToggle() throws {
        let model = StubModel()

        Just(())
            .toggle(\.flag, on: model)
            .sink { (_) in XCTAssertEqual(model.current(\.flag), true) }
                receiveValue: { (_) in }
            .store(in: &subscriptions)
    }

    func testPublisherToggle_SeveralTimes() throws {
        let model = StubModel()

        [1, 2, 3, 4].publisher
            .toggle(\.flag, on: model)
            .sink { (_) in XCTAssertEqual(model.current(\.flag), false) }
                receiveValue: { (_) in }
            .store(in: &subscriptions)
    }
}

extension DatabaseModelTests {

    final class StubEntity: NSManagedObject, FetchableEntity {

        static func fetchRequest() -> NSFetchRequest<StubEntity> {
            NSFetchRequest<StubEntity>(entityName: "Stub")
        }

        @objc var flag = false
        @objc var property: String? = ""
    }

    struct StubModel: DatabaseModel {

        let _entityWrapper = EntityWrapper(entity: StubEntity())

        let property = Field(\.property, validations: .doesNotContain("Yo"))
        let flag = Field(\.flag)

        init(entity: StubEntity) {}

        init() {}
    }
}
