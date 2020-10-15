//
// Copyright © 2018-present Amaris Software.
//

import Foundation

public enum CoreDataCandyError: LocalizedError, ConversionError {

    case outputConversion(keyPath: String)
    case storeConversion(keyPath: String)
    case dataValidation(description: String)
    case unableToSaveContext(reason: String)
    case unknown

    public var errorDescription: String? {
        switch self {
        case .outputConversion(let keyPath): return "Error while converting the value from the stored one at '\(keyPath)'."
        case .storeConversion(let keyPath): return "Error while converting the value to the stored one at '\(keyPath)'."
        case .dataValidation(let description): return "Data validation error. \(description)"
        case .unableToSaveContext(let reason): return "Unable to save the context. \(reason)"
        case .unknown: return "Unknown or not handled error"
        }
    }
}
