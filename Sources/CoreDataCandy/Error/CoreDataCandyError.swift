//
// Copyright © 2018-present Amaris Software.
//

import Foundation

public enum CoreDataCandyError: LocalizedError, ConversionError {

    case outputConversion
    case storeConversion
    case dataValidation(description: String)
    case unableToSaveContext(reason: String)
    case unknown

    public var errorDescription: String? {
        switch self {
        case .outputConversion: return "Error while converting the value from the stored one"
        case .storeConversion: return "Error while converting the value to the stored one"
        case .dataValidation(let description): return description
        case .unableToSaveContext(let reason): return "Unable to save the context. \(reason)"
        case .unknown: return "Unknown or not handled error"
        }
    }
}
