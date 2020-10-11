//
// Copyright © 2018-present Amaris Software.
//

import Foundation

public extension KeyPath {

    /// Name of the property pointed at
    var label: String { NSExpression(forKeyPath: self).keyPath }
}
