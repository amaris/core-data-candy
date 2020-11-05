//
// Copyright © 2018-present Amaris Software.
//

import Foundation
import CoreData

/// A predicate operator and its right operand to be speficied when fetching in CoreData
public struct OperatorPredicate<LeftValue, RightValue> {

    // MARK: - Constants

    public typealias Formatter = (String) -> String
    public typealias ArgumentsOrder = (Any) -> [Any]

    // MARK: - Properties

    let value: RightValue
    let formatter: Formatter
    let argumentsOrder: ArgumentsOrder

    // MARK: - Initialisation

    public init(operatorString: String, value: RightValue, isInverted: Bool = false) {
        self.value = value
        self.formatter = { valueString in
            isInverted ? "NOT \(valueString) \(operatorString) %@" : "\(valueString) \(operatorString) %@"
        }
        self.argumentsOrder = { [$0, value] }
    }

    public init(value: RightValue, isInverted: Bool = false, formatter: @escaping Formatter, argumentsOrder: ArgumentsOrder? = nil) {
        self.value = value
        self.formatter = formatter
        self.argumentsOrder = argumentsOrder ?? { [$0, value] }
    }

    // MARK: - Functions

    /// Returns a predicate using a keypath operand with the given keypath
    public func predicate<R: FetchableEntity, V>(for keyPath: KeyPath<R, V>) -> NSPredicate {
        let arguments = argumentsOrder(keyPath.label)
        let format = formatter("%K")

        return NSPredicate(format: format, argumentArray: arguments)
    }
}
