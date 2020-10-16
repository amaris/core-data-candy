//
// Copyright © 2018-present Amaris Software.
//

import Foundation

/// A Coding key used to decode/encode into JSON to communicate with the API
public struct FieldCodingKey: CodingKey, Hashable {
    public var stringValue: String
    public var intValue: Int?

    init(name: String) {
        stringValue = name
    }

    public init?(stringValue: String) {
        self.stringValue = stringValue
    }

    public init?(intValue: Int) {
        self.intValue = intValue
        stringValue = String(intValue)
    }
}

extension FieldCodingKey: ExpressibleByStringLiteral {

    public init(stringLiteral value: String) {
        stringValue = value
    }
}
