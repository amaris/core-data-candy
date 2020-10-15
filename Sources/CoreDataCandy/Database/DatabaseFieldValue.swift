//
// Copyright © 2018-present Amaris Software.
//

import Foundation

/// Value type that a CoreData attribute can take
public protocol DatabaseFieldValue {}

extension Bool: DatabaseFieldValue {}
extension Date: DatabaseFieldValue {}
extension String: DatabaseFieldValue {}
extension Int16: DatabaseFieldValue {}
extension Int32: DatabaseFieldValue {}
extension Int64: DatabaseFieldValue {}
extension Double: DatabaseFieldValue {}
extension Data: DatabaseFieldValue {}
extension URL: DatabaseFieldValue {}
extension UUID: DatabaseFieldValue {}
extension NSObject: DatabaseFieldValue {}
extension Optional: DatabaseFieldValue where Wrapped: DatabaseFieldValue {}
