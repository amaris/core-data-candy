//
// CoreDataCandy
// Copyright © 2018-present Amaris Software.
// MIT license, see LICENSE file for details

import XCTest
import CoreDataCandy

final class ValidationsTests: XCTestCase {

    func testIsEmail_IsValid() throws {
        let emails = ["test@email.com",
                      "t@email.co",
                      "test@e.com",
                      "test+topic@email.com",
                      "t_t@email.com",
                      "0@email.com"]

        try emails.forEach { email in
            XCTAssertNoThrow(try Validation.isEmail.validate(email))
        }
    }

    func testIsEmail_IsInvalid() throws {
        let emails = ["@email.com",
                      "t@.co",
                      "test@e.c",
                      "test@example.c",
                      "test@example",
                      "é@email.com",
                      "e@ma:l.com"]

        try emails.forEach { email in
            XCTAssertThrowsError(try Validation.isEmail.validate(email))
        }
    }
}
