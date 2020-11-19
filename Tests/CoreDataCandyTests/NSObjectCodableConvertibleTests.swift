//
// Copyright © 2018-present Amaris Software.
//

import XCTest
import CoreDataCandy

extension NSPredicate: CodableConvertible {}

final class NSObjectCodableCodalbeConvertibleTests: XCTestCase {

    func testNSPredicate() throws {
        let predicate = NSPredicate(format: "unit == 2")
        let data = try JSONEncoder().encode(predicate.codableModel)
        let result = try JSONDecoder().decode(NSObjectCodableModel<NSPredicate>.self, from: data)

        XCTAssertEqual(predicate, result.converted)
    }
}
