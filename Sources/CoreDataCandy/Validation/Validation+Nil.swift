//
// Copyright © 2018-present Amaris Software.
//

import Foundation

/** NOTE: I could not find to way to make this work properly with `Value == DatabaseFieldValue?` and a static property */

public extension Validation where Value: ExpressibleByNilLiteral {

    static func notNil<U>() -> Self where Value == U? {
        Validation { value in
            if value == nil {
                throw CoreDataCandyError.dataValidation(description: "Nil value not allowed for this field")
            }
        }
    }
}
