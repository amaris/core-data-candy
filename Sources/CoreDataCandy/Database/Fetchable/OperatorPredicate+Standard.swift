//
// Copyright © 2018-present Amaris Software.
//

// MARK: - Comparable

public extension OperatorPredicate where RightValue: Comparable {

    /// `true` if the given values contains the left operand
    static func isIn<V: DatabaseFieldValue>(_ value: [V]) -> OperatorPredicate<[V]> {
        OperatorPredicate<[V]>(operatorString: "IN", value: value)
    }

    /// `true` if the given values contains the left operand
    static func isIn<V: DatabaseFieldValue>(_ value: V...) -> OperatorPredicate<[V]> {
        OperatorPredicate<[V]>(operatorString: "IN", value: value)
    }

    /// `false` if the given values contains the left operand
    static func isNot<V: DatabaseFieldValue>(in value: [V]) -> OperatorPredicate<[V]> {
        OperatorPredicate<[V]>(operatorString: "IN", value: value, isInverted: true)
    }

    /// `false` if the given values contains the left operand
    static func isNot<V: DatabaseFieldValue>(in value: V...) -> OperatorPredicate<[V]> {
        OperatorPredicate<[V]>(operatorString: "IN", value: value, isInverted: true)
    }
}

// MARK: - String

public extension OperatorPredicate where RightValue == String {

    static func hasPrefix(_ prefix: String) -> OperatorPredicate<String> {
        OperatorPredicate<String>(operatorString: "BEGINSWITH", value: prefix)
    }

    static func hasSuffix(_ suffix: String) -> OperatorPredicate<String> {
        OperatorPredicate<String>(operatorString: "ENDSWITH", value: suffix)
    }

    static func contains(_ value: String) -> OperatorPredicate<String> {
        OperatorPredicate<String>(operatorString: "CONTAINS", value: value)
    }

    /// `true` if the given regular expression matches the left operand
    static func matches(_ value: RegularExpressionPattern) -> OperatorPredicate<String> {
        OperatorPredicate<String>(operatorString: "MATCHES", value: value.pattern)
    }
}

// MARK: - Numeric & Comparable

public extension OperatorPredicate where RightValue: Numeric, RightValue: Comparable {

    /// `true` if the given range contains the left operand
    static func isIn(_ range: ClosedRange<RightValue>) -> OperatorPredicate<[RightValue]> {
        OperatorPredicate<[RightValue]>(operatorString: "BETWEEN", value: [range.lowerBound, range.upperBound])
    }

    /// `false` if the given range contains the left operand
    static func isNot(in range: ClosedRange<RightValue>) -> OperatorPredicate<[RightValue]> {
        OperatorPredicate<[RightValue]>(operatorString: "BETWEEN", value: [range.lowerBound, range.upperBound], isInverted: true)
    }

    /// `true` if the given range contains the left operand
    static func isIn(_ range: Range<RightValue>) -> OperatorPredicate<[RightValue]> {
        OperatorPredicate<[RightValue]>(value: [range.lowerBound, range.upperBound]) { (valueString) -> String in
            "( %@ <= \(valueString) ) && ( \(valueString) < %@ )"
        } argumentsOrder: { (argument) -> [Any] in
            [range.lowerBound, argument, range.upperBound, argument]
        }
    }

    /// `false` if the given range contains the left operand
    static func isNot(in range: Range<RightValue>) -> OperatorPredicate<[RightValue]> {
        OperatorPredicate<[RightValue]>(value: [range.lowerBound, range.upperBound], isInverted: true) { (valueString) -> String in
            "NOT ( %@ <= \(valueString) ) OR NOT ( \(valueString) < %@ )"
        } argumentsOrder: { (argument) -> [Any] in
            [range.lowerBound, argument, range.upperBound, argument]
        }
    }
}
