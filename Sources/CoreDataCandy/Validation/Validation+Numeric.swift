//
// Copyright © 2018-present Amaris Software.
//

public extension Validation where Value: Numeric & Comparable {

    static func isIn(_ range: ClosedRange<Value>) -> Self {
        Validation {
            if !range.contains($0) {
                throw CoreDataCandyError.dataValidation(description: "Value \($0) is not within \(range.description)")
            }
        }
    }

    static func isIn(_ range: Range<Value>) -> Self {
        Validation {
            if !range.contains($0) {
                throw CoreDataCandyError.dataValidation(description: "Value \($0) is not within \(range.description)")
            }
        }
    }

    static func greaterThan(_ bound: Value) -> Self {
        Validation {
            if bound >= $0 {
                throw CoreDataCandyError.dataValidation(description: "Value \($0) is not greater than \(bound)")
            }
        }
    }

    static func greaterThanOrEqualTo(_ bound: Value) -> Self {
        Validation {
            if bound > $0 {
                throw CoreDataCandyError.dataValidation(description: "Value \($0) is not greater than or equal to \(bound)")
            }
        }
    }

    static func lesserThan(_ bound: Value) -> Self {
        Validation {
            if bound <= $0 {
                throw CoreDataCandyError.dataValidation(description: "Value \($0) is not lesser than \(bound)")
            }
        }
    }

    static func lesserThanOrEqualTo(_ bound: Value) -> Self {
        Validation {
            if bound < $0 {
                throw CoreDataCandyError.dataValidation(description: "Value \($0) is not lesser than or equal to \(bound)")
            }
        }
    }
}
