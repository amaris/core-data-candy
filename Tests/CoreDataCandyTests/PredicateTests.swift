//
// Copyright © 2018-present Amaris Software.
//

import XCTest
import CoreData
import CoreDataCandy

final class PredicateTests: XCTestCase {

    func testComparisonFormats() {
        testNSFormat(predicate: .where(\.property == "Donald"), expecting: #"property == "Donald""#)
        testNSFormat(predicate: .where(\.property != "Donald"), expecting: #"property != "Donald""#)
        testNSFormat(predicate: .where(\.score > 10), expecting: "score > 10")
        testNSFormat(predicate: .where(\.score >= 10), expecting: "score >= 10")
        testNSFormat(predicate: .where(\.score < 10), expecting: "score < 10")
        testNSFormat(predicate: .where(\.score <= 10), expecting: "score <= 10")
    }

    func testString() {
        testNSFormat(predicate: .where(\.property, hasPrefix: "Desp"), expecting: #"property BEGINSWITH "Desp""#)
        testNSFormat(predicate: .where(\.property, hasNoPrefix: "Desp"), expecting: #"NOT property BEGINSWITH "Desp""#)
        testNSFormat(predicate: .where(\.property, hasSuffix: "Desp"), expecting: #"property ENDSWITH "Desp""#)
        testNSFormat(predicate: .where(\.property, hasNoSuffix: "Desp"), expecting: #"NOT property ENDSWITH "Desp""#)
        testNSFormat(predicate: .where(\.property, contains: "Desp"), expecting: #"property CONTAINS "Desp""#)
        testNSFormat(predicate: .where(\.property, doesNotContain: "Desp"), expecting: #"NOT property CONTAINS "Desp""#)
        testNSFormat(predicate: .where(\.property, matches: ".*"), expecting: #"property MATCHES ".*""#)
        testNSFormat(predicate: .where(\.property, doesNotMatch: ".*"), expecting: #"NOT property MATCHES ".*""#)
    }

    func testAdvancedFormats() {
        testNSFormat(predicate: .where(\.property, isIn: ["Riri", "Fifi"]), expecting: #"property IN {"Riri", "Fifi"}"#)
        testNSFormat(predicate: .where(\.property, isNotIn: "Riri", "Fifi"), expecting: #"NOT property IN {"Riri", "Fifi"}"#)
        testNSFormat(predicate: .where(\.property, isIn: ["Riri", "Fifi"]), expecting: #"property IN {"Riri", "Fifi"}"#)
        testNSFormat(predicate: .where(\.property, isNotIn: ["Riri", "Fifi"]), expecting: #"NOT property IN {"Riri", "Fifi"}"#)
        testNSFormat(predicate: .where(\.score, isIn: 1...10), expecting: #"score BETWEEN {1, 10}"#)
        testNSFormat(predicate: .where(\.score, isNotIn: 1...10), expecting: #"NOT score BETWEEN {1, 10}"#)
        testNSFormat(predicate: .where(\.score, isIn: 1..<10.5), expecting: #"1 <= score AND score < 10.5"#)
        testNSFormat(predicate: .where(\.score, isNotIn: 1..<10.5), expecting: #"1 > score OR score >= 10.5"#)
    }
}

extension PredicateTests {

    func testNSFormat<Value: DatabaseFieldValue, TestValue>(predicate: Predicate<StubEntity, Value, TestValue>, expecting format: String) {
        XCTAssertEqual(predicate.nsValue.predicateFormat, format)
    }

    final class StubEntity: NSManagedObject, FetchableEntity {

        static func fetchRequest() -> NSFetchRequest<StubEntity> { NSFetchRequest<StubEntity>(entityName: "Stub") }

        @objc var score = 0.0
        @objc var property: String? = ""
    }
}
