//
// Copyright © 2018-present Amaris Software.
//

import Foundation

public extension Validation where Value == String {

    static let notEmpty: Self = {
        Validation {
            if $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                throw CoreDataCandyError.dataValidation(description: "\($0) should not be empty")
            }
        }
    }()

    static func hasPrefix(_ prefix: String) -> Self {
        Validation {
            if !$0.hasPrefix(prefix) {
                throw CoreDataCandyError.dataValidation(description: "\($0) should start with \(prefix)")
            }
        }
    }

    static func hasSuffix(_ suffix: String) -> Self {
        Validation {
            if !$0.hasSuffix(suffix) {
                throw CoreDataCandyError.dataValidation(description: "\($0) should end with \(suffix)")
            }
        }
    }

    static func contains(_ string: String) -> Self {
        Validation {
            if !$0.contains(string) {
                throw CoreDataCandyError.dataValidation(description: "\($0) should contain \(string)")
            }
        }
    }

    static func doesNotContain(_ string: String) -> Self {
        Validation {
            if $0.contains(string) {
                throw CoreDataCandyError.dataValidation(description: "\($0) should not contain \(string)")
            }
        }
    }

    static func count(_ count: Int) -> Self {
        Validation {
            if $0.count != count {
                throw CoreDataCandyError.dataValidation(description: "\($0) should have \(count) character(s)")
            }
        }
    }

    static let isEmail: Self = {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegex)

        return Validation {
            if !emailPred.evaluate(with: $0) {
                throw CoreDataCandyError.dataValidation(description: "\($0) is not a valid email")
            }
        }
    }()
}
