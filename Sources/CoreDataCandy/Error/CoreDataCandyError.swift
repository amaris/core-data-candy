//
// CoreDataCandy
// Copyright © 2018-present Amaris Software.
// MIT license, see LICENSE file for details

import Foundation

public enum CoreDataCandyError: LocalizedError {

    case outputConversion
    case storeConversion
    case dataValidation(description: String)
    case existingUnique(field: String, value: String, model: String)
    case unableToSaveContext(reason: String)
    case nsObjectDecodingError(_ object: NSObject.Type)
    case unknown

    public var errorDescription: String? {
        switch self {
        case .outputConversion: return "Error while converting the value from the database stored one."
        case .storeConversion: return "Error while converting the value to the database stored one."
        case .dataValidation(let description): return "Data validation error. \(description)"
        case .unableToSaveContext(let reason): return "Unable to save the context. \(reason)"
        case .unknown: return "Unknown or not handled error"
        case .nsObjectDecodingError(let object): return "Unable to decode stored data as \(object.self)"
        case .existingUnique(field: let field, value: let value, model: let model):
            return "A \(model) with the value \(value) for the field \(field) already exists."
        }
    }
}
