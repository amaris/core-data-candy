//
// Copyright © 2018-present Amaris Software.
//

import XCTest
@testable import CoreDataCandy

final class SortTests: XCTestCase {

    let riri = StubStruct(name: "Riri", score: 20)
    let fifi = StubStruct(name: "Fifi", score: 10)
    let loulou = StubStruct(name: "Loulou", score: 40)
    let donald = StubStruct(name: "Donald", score: 20)

    var stubs1: [StubStruct] { [riri, fifi, loulou] }
    var stubs2: [StubStruct] { stubs1 + [donald] }

    func testAscending() {
        XCTAssertEqual(stubs1.sorted(by: .ascending(\.name)), [fifi, loulou, riri])
    }

    func testDescending() {
        XCTAssertEqual(stubs1.sorted(by: .descending(\.score)), [loulou, riri, fifi])
    }

    func testTwoSorts() {
        XCTAssertEqual(stubs2.sorted(by: .descending(\.score), .ascending(\.name)), [loulou, donald, riri, fifi])
    }
}

extension SortTests {

    struct StubStruct: Equatable {
        var name: String
        var score: Double
    }
}
