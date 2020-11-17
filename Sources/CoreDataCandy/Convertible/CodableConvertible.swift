//
// Copyright © 2018-present Amaris Software.
//

import Foundation

/// A `Codable` object used as the codable model of a `CodableConvertible`
public protocol CodableConvertibleModel: Codable {
    associatedtype Convertible: CodableConvertible where Convertible.CodableModel == Self

    var converted: Convertible { get }
}

/// Can be converted  to a  `CodableConvertibleModel`
public protocol CodableConvertible {
    associatedtype CodableModel: CodableConvertibleModel where CodableModel.Convertible == Self

    var codableModel: CodableModel { get }
}