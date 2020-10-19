//
// Copyright © 2018-present Amaris Software.
//

import XCTest
import CoreData
import CoreDataCandy

final class PredicateOperatorTests: XCTestCase {

    func testFormat() {
        let predOperator = OperatorPredicate<Int, Int>(operatorString: ">", value: 10)
        let predicate = predOperator.predicate(for: \StubEntity.property)

        XCTAssertEqual(predicate.predicateFormat, "property > 10")
    }

    func testFormatInverted() {
        let predOperator = OperatorPredicate<Int, Int>(operatorString: ">", value: 10, isInverted: true)
        let predicate = predOperator.predicate(for: \StubEntity.property)

        XCTAssertEqual(predicate.predicateFormat, "NOT property > 10")
    }
}

extension PredicateOperatorTests {

    final class StubEntity: NSManagedObject, FetchResultEntity {
        static func fetchRequest() -> NSFetchRequest<StubEntity> {
            NSFetchRequest<StubEntity>(entityName: "Stub")
        }

        @objc var property = ""
    }
}
