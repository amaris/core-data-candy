//
// Copyright © 2018-present Amaris Software.
//

import Foundation

extension Collection where Element: DatabaseModel, Element.Entity: FetchableEntity {

    func sorted<Value: Comparable>(with sort: Sort<Element.Entity, Value>) -> [Element] {
        sorted { sort.compare($0.entity[keyPath: sort.keyPath], $1.entity[keyPath: sort.keyPath]) }
    }
}
