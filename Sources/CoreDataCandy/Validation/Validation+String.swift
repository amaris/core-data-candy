//
// Copyright © 2018-present Amaris Software.
//

public extension Validation where Value == String {

    static let notEmpty: Self = {
        Validation {
            if $0.isEmpty {
                throw CoreDataCandyError.dataValidation(description: "Value \($0) should not be empty")
            }
        }
    }()

    static func hasPrefix(_ prefix: String) -> Self {
        Validation {
            if !$0.hasPrefix(prefix) {
                throw CoreDataCandyError.dataValidation(description: "Value \($0) should start with \(prefix)")
            }
        }
    }

    static func hasSuffix(_ suffix: String) -> Self {
        Validation {
            if !$0.hasSuffix(suffix) {
                throw CoreDataCandyError.dataValidation(description: "Value \($0) should end with \(suffix)")
            }
        }
    }

    static func count(_ count: Int) -> Self {
        Validation {
            if $0.count != count {
                throw CoreDataCandyError.dataValidation(description: "Value \($0) should \(count) characters")
            }
        }
    }
}
