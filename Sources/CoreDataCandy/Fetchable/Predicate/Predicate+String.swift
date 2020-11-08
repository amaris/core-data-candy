//
// Copyright © 2018-present Amaris Software.
//

import Foundation

public extension Predicate where Value == String? {

    /// `true` if the property starts with the prefix
    static func `where`(_ keyPath: KeyPath<E, Value>, hasPrefix prefix: String) -> Predicate<E, Value, String> {
        .init(keyPath: keyPath, operatorString: "BEGINSWITH", value: prefix)
    }

    /// `false` if the property starts with the prefix
    static func `where`(_ keyPath: KeyPath<E, Value>, hasNoPrefix prefix: String) -> Predicate<E, Value, String> {
        .init(keyPath: keyPath, operatorString: "BEGINSWITH", value: prefix, isInverted: true)
    }

    /// `true` if the property ends with the prefix
    static func `where`(_ keyPath: KeyPath<E, Value>, hasSuffix suffix: String) -> Predicate<E, Value, String> {
        .init(keyPath: keyPath, operatorString: "ENDSWITH", value: suffix)
    }

    /// `false` if the property ends with the prefix
    static func `where`(_ keyPath: KeyPath<E, Value>, hasNoSuffix suffix: String) -> Predicate<E, Value, String> {
        .init(keyPath: keyPath, operatorString: "ENDSWITH", value: suffix, isInverted: true)
    }

    /// `true` if the property contains the other string
    static func `where`(_ keyPath: KeyPath<E, Value>, contains otherString: String) -> Predicate<E, Value, String> {
        .init(keyPath: keyPath, operatorString: "CONTAINS", value: otherString)
    }

    /// `false` if the property contains the other string
    static func `where`(_ keyPath: KeyPath<E, Value>, doesNotContain otherString: String) -> Predicate<E, Value, String> {
        .init(keyPath: keyPath, operatorString: "CONTAINS", value: otherString, isInverted: true)
    }

    /// `true` if the property contains the other string
    static func `where`(_ keyPath: KeyPath<E, Value>, matches pattern: RegularExpressionPattern) -> Predicate<E, Value, String> {
        .init(keyPath: keyPath, operatorString: "MATCHES", value: pattern.stringValue)
    }

    /// `false` if the property contains the other string
    static func `where`(_ keyPath: KeyPath<E, Value>, doesNotMatch pattern: RegularExpressionPattern) -> Predicate<E, Value, String> {
        .init(keyPath: keyPath, operatorString: "MATCHES", value: pattern.stringValue, isInverted: true)
    }
}
