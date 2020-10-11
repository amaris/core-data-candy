//
// Copyright © 2018-present Amaris Software.
//

import Foundation

/// Can be converted to `NSObject`
public protocol NSObjectConvertible {

    var nsObject: NSObject { get }

    init?(from object: NSObject)
}

extension NSObjectConvertible where Self: NSObject {
    public var nsObject: NSObject { self }

    public init?(from object: NSObject) {
        if let converted = object as? Self {
            self = converted
        } else {
            return nil
        }
    }
}
