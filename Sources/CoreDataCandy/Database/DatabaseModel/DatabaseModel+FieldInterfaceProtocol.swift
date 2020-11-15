//
// Copyright © 2018-present Amaris Software.
//

public extension DatabaseModel {

    /// The current value of the given field
    func current<F: FieldInterfaceProtocol>(_ keyPath: KeyPath<Self, F>) -> F.Value
    where F.Entity == Entity, F.StoreConversionError == Never {
        self[keyPath: keyPath].currentValue(in: entity)
    }

    /// The current value of the given field
    func current<F: FieldInterfaceProtocol>(_ keyPath: KeyPath<Self, F>) -> F.Value
    where F.Entity == Entity, F.FieldValue: ExpressibleByNilLiteral, F.StoreConversionError == CoreDataCandyError, F.Value: ExpressibleByNilLiteral {
        self[keyPath: keyPath].currentValue(in: entity)
    }
}
