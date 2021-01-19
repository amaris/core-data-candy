//
// CoreDataCandy
// Copyright © 2018-present Amaris Software.
// MIT license, see LICENSE file for details

import Foundation

/// Value types that a CoreData attribute can take
public protocol DatabaseFieldValue: Equatable {}

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
extension Array: DatabaseFieldValue where Element: DatabaseFieldValue {}

/** Int cannot be stored as a Core Data type but we make it implement the DatabaseFieldValue
 protocol for fetching. Anyway, it will not be possible to target an Int property of a
 CoreData entity from a FieldWrapper */
extension Int: DatabaseFieldValue {}
