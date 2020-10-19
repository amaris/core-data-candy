//
// Copyright © 2018-present Amaris Software.
//

public extension OperatorPredicate {

    // MARK: Array

    /// `true` if the given values contains the left operand
    static func isIn<V: DatabaseFieldValue & Comparable>(_ value: [V]) -> OperatorPredicate<V, [V]> {
        OperatorPredicate<V, [V]>(operatorString: "IN", value: value)
    }

    /// `true` if the given values contains the left operand
    static func isIn<V: DatabaseFieldValue & Comparable>(_ value: V...) -> OperatorPredicate<V, [V]> {
        OperatorPredicate<V, [V]>(operatorString: "IN", value: value)
    }

    /// `false` if the given values contains the left operand
    static func isNot<V: DatabaseFieldValue & Comparable>(in value: [V]) -> OperatorPredicate<V, [V]> {
        OperatorPredicate<V, [V]>(operatorString: "IN", value: value, isInverted: true)
    }

    /// `false` if the given values contains the left operand
    static func isNot<V: DatabaseFieldValue & Comparable>(in value: V...) -> OperatorPredicate<V, [V]> {
        OperatorPredicate<V, [V]>(operatorString: "IN", value: value, isInverted: true)
    }

    // MARK: String

    static func has(prefix value: String) -> OperatorPredicate<String, String> {
        OperatorPredicate<String, String>(operatorString: "BEGINSWITH", value: value)
    }

    static func has(suffix value: String) -> OperatorPredicate<String, String> {
        OperatorPredicate<String, String>(operatorString: "ENDSWITH", value: value)
    }

    static func contains(_ value: String) -> OperatorPredicate<String, String> {
        OperatorPredicate<String, String>(operatorString: "CONTAINS", value: value)
    }

    // MARK: Numeric

    /// `true` if the given range contains the left operand
    static func isIn<N: Numeric>(_ range: ClosedRange<N>) -> OperatorPredicate<N, [N]> {
        OperatorPredicate<N, [N]>(operatorString: "BETWEEN", value: [range.lowerBound, range.upperBound])
    }

    /// `false` if the given range contains the left operand
    static func isNot<N: Numeric>(in range: ClosedRange<N>) -> OperatorPredicate<N, [N]> {
        OperatorPredicate<N, [N]>(operatorString: "BETWEEN", value: [range.lowerBound, range.upperBound], isInverted: true)
    }

    /// `true` if the given range contains the left operand
    static func isIn<N: Numeric>(_ range: Range<N>) -> OperatorPredicate<N, [N]> {
        OperatorPredicate<N, [N]>(value: [range.lowerBound, range.upperBound]) { (valueString) -> String in
            "( %@ <= \(valueString) ) && ( \(valueString) < %@ )"
        } argumentsOrder: { (argument) -> [Any] in
            [range.lowerBound, argument, range.upperBound, argument]
        }
    }

    /// `false` if the given range contains the left operand
    static func isNot<N: Numeric>(in range: Range<N>) -> OperatorPredicate<N, [N]> {
        OperatorPredicate<N, [N]>(value: [range.lowerBound, range.upperBound], isInverted: true) { (valueString) -> String in
            "NOT ( %@ <= \(valueString) ) OR NOT ( \(valueString) < %@ )"
        } argumentsOrder: { (argument) -> [Any] in
            [range.lowerBound, argument, range.upperBound, argument]
        }
    }

    // MARK: Regular expression

    /// `true` if the given regular expression matches the left operand
    static func matches(_ value: RegularExpressionPattern) -> OperatorPredicate<String, String> {
        OperatorPredicate<String, String>(operatorString: "MATCHES", value: value.pattern)
    }
}
