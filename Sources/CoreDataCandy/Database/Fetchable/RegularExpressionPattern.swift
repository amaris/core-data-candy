//
// Copyright © 2018-present Amaris Software.
//

import Foundation

public struct RegularExpressionPattern {
    public let pattern: String
}

extension RegularExpressionPattern: ExpressibleByStringLiteral {

    public init(stringLiteral value: String) {
        pattern = value
    }
}
