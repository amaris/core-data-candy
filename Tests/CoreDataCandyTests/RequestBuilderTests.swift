//
// Copyright © 2018-present Amaris Software.
//

@testable import CoreDataCandy
import XCTest

final class RequestBuilderTests: XCTestCase {

    var request: RequestBuilder<StubEntity, TargetStep, StubEntity?>!

    override func setUp() {
        let fetchRequest = NSFetchRequest<StubEntity>()
        request = RequestBuilder<StubEntity, TargetStep, StubEntity?>(request: fetchRequest)
    }

    func testCompoundPredicate() {
        testNSFormat(builder: request.where(\.property == "Donald").or(\.score == 20.0),
                     expecting: #"property == "Donald" OR score == 20"#)

        testNSFormat(builder: request.where(\.property == "Donald").and(\.score == 20.0),
                     expecting: #"property == "Donald" AND score == 20"#)

        testNSFormat(builder: request.where(\.property == "Donald").or(\.name, .hasPrefix("Jo")).and(\.score == 20.0),
                     expecting: #"(property == "Donald" OR name BEGINSWITH "Jo") AND score == 20"#)

        testNSFormat(builder: request.where(\.property == "Donald").or(\.name, .hasPrefix("Jo")).or(\.score == 20.0),
                     expecting: #"property == "Donald" OR name BEGINSWITH "Jo" OR score == 20"#)
    }
}

extension RequestBuilderTests {

    final class StubEntity: NSManagedObject, FetchableEntity {

        static func fetchRequest() -> NSFetchRequest<StubEntity> { NSFetchRequest<StubEntity>(entityName: "Stub") }

        @objc var name: String?
        @objc var score = 0.0
        @objc var property: String? = ""
    }
}

extension RequestBuilderTests {

    func testNSFormat(builder: RequestBuilder<StubEntity, PredicateStep, StubEntity?>, expecting format: String) {
        XCTAssertEqual(builder.request.predicate?.predicateFormat, format)
    }
}
