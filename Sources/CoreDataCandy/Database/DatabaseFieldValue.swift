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

/** Int cannot be stored a Core Data type but we make it implement the DatabaseFieldValue
 protocol  anyway for fetching. Anyway, it will not be possible to target a Int property of a
 CoreData entity from a FieldWrapper */
extension Int: DatabaseFieldValue {}
