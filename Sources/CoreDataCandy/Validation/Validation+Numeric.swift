//
// Copyright © 2018-present Amaris Software.
//

public extension Validation where Value: Numeric & Comparable {

    static func range(_ range: ClosedRange<Value>) -> Self {
        Validation {
            if !range.contains($0) {
                throw CoreDataCandyError.dataValidation(description: "Value \($0) is not within \(range.description)")
            }
        }
    }
}
