//
// Copyright © 2018-present Amaris Software.
//

import Foundation
import CoreData

extension KeyPath where Root: FetchResultEntity {

    /// Name of the property pointed at
    var label: String { NSExpression(forKeyPath: self).keyPath }
}
