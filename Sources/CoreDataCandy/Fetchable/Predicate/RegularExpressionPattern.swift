//
// CoreDataCandy
// Copyright © 2018-present Amaris Software.
// MIT license, see LICENSE file for details

import Foundation

/// Holds a reqular expression pattern
/// - note: This wrapper mainly exists to offer a way to specify patterns in extensions, while
/// preventing those extensions to be on `String`
public struct RegularExpressionPattern {
    public let stringValue: String
}

extension RegularExpressionPattern: ExpressibleByStringLiteral {

    public init(stringLiteral value: String) {
        stringValue = value
    }
}
