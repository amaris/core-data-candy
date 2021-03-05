//
// CoreDataCandy
// Copyright © 2018-present Amaris Software.
// MIT license, see LICENSE file for details

import XCTest
import CoreData
import CoreDataCandy

final class PredicateTests: XCTestCase {

    func testComparisonFormats() {
        testNSFormat(predicate: \.property == "Donald", expecting: #"property == "Donald""#)
        testNSFormat(predicate: \.property != "Donald", expecting: #"property != "Donald""#)
        testNSFormat(predicate: \.score > 10, expecting: "score > 10")
        testNSFormat(predicate: \.score >= 10, expecting: "score >= 10")
        testNSFormat(predicate: \.score < 10, expecting: "score < 10")
        testNSFormat(predicate: \.score <= 10, expecting: "score <= 10")
    }

    func testString() {
        testNSFormat(\.property, .hasPrefix("Desp"), expecting: #"property BEGINSWITH "Desp""#)
        testNSFormat(\.property, .hasNoPrefix("Desp"), expecting: #"NOT property BEGINSWITH "Desp""#)
        testNSFormat(\.property, .hasSuffix("Desp"), expecting: #"property ENDSWITH "Desp""#)
        testNSFormat(\.property, .hasNoSuffix("Desp"), expecting: #"NOT property ENDSWITH "Desp""#)
        testNSFormat(\.property, .contains("Desp"), expecting: #"property CONTAINS "Desp""#)
        testNSFormat(\.property, .doesNotContain("Desp"), expecting: #"NOT property CONTAINS "Desp""#)
        testNSFormat(\.property, .matches(".*"), expecting: #"property MATCHES ".*""#)
        testNSFormat(\.property, .doesNotMatch(".*"), expecting: #"NOT property MATCHES ".*""#)
    }

    func testAdvancedFormats() {
        testNSFormat(\.property, .isIn(["Riri", "Fifi"]), expecting: #"property IN {"Riri", "Fifi"}"#)
        testNSFormat(\.property, .isNotIn("Riri", "Fifi"), expecting: #"NOT property IN {"Riri", "Fifi"}"#)
        testNSFormat(\.property, .isIn(["Riri", "Fifi"]), expecting: #"property IN {"Riri", "Fifi"}"#)
        testNSFormat(\.property, .isNotIn(["Riri", "Fifi"]), expecting: #"NOT property IN {"Riri", "Fifi"}"#)
        testNSFormat(\.score, .isIn(1...10), expecting: #"score BETWEEN {1, 10}"#)
        testNSFormat(\.score, .isNotIn(1...10), expecting: #"NOT score BETWEEN {1, 10}"#)
        testNSFormat(\.score, .isIn(1..<10.5), expecting: #"1 <= score AND score < 10.5"#)
        testNSFormat(\.score, .isNotIn(1..<10.5), expecting: #"1 > score OR score >= 10.5"#)
    }
}

extension PredicateTests {

    func testNSFormat<Value: DatabaseFieldValue, TestValue>(predicate: FetchPredicate<StubEntity, Value, TestValue>, expecting format: String) {
        XCTAssertEqual(predicate.nsValue.predicateFormat, format)
    }

    func testNSFormat<Value: DatabaseFieldValue, TestValue>(_ keyPath: KeyPath<StubEntity, Value>, _ predicateRightValue: PredicateRightValue<StubEntity, Value, TestValue>, expecting format: String) {
        let predicateFormat = predicateRightValue.predicate(keyPath).nsValue.predicateFormat
        XCTAssertEqual(predicateFormat, format)
    }

    final class StubEntity: NSManagedObject, DatabaseEntity {

        static func fetchRequest() -> NSFetchRequest<StubEntity> { NSFetchRequest<StubEntity>(entityName: "Stub") }

        @objc var score = 0.0
        @objc var property: String? = ""
    }
}
