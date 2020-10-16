//
// Copyright © 2018-present Amaris Software.
//

import Foundation

public protocol ConversionError: Error {
    static var unknown: Self { get }
}

extension Never: ConversionError {
    public static var unknown: Never { fatalError("Empty implementation for the protocol ConversionError") }
}
