//
// Copyright © 2018-present Amaris Software.
//

import Foundation

public struct NSObjectCodableModel<Object: NSObject>: CodableConvertibleModel where Object: CodableConvertible {

    public var converted: Object

    public init(object: Object) {
        self.converted = object
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let dataObject = try container.decode(Data.self)
        guard let object = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(dataObject) as? Object else {
            throw CoreDataCandyError.nsObjectDecodingError(Object.self)
        }
        converted = object
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let objectData = try NSKeyedArchiver.archivedData(withRootObject: converted, requiringSecureCoding: true)
        try container.encode(objectData)
    }
}

public extension CodableConvertible where Self: NSObject {

    var codableModel: NSObjectCodableModel<Self> { .init(object: self) }
}
