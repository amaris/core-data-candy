//
// Copyright © 2018-present Amaris Software.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Can be instantiated and converted to with/to a `Data` object,
public protocol DataConvertible {
  var data: Data? { get }

  init?(data: Data)
}

#if canImport(UIKit)
extension UIImage: DataConvertible {
    public var data: Data? { pngData() }
    public var png: Data? { pngData() }
    public var jpeg: Data? { jpegData(compressionQuality: 0.8) }
}
#endif
