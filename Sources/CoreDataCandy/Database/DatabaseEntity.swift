//
// Copyright © 2018-present Amaris Software.
//

import CoreData

/// An enitity in CoreData
public protocol DatabaseEntity: NSFetchRequestResult {
    static func fetchRequest() -> NSFetchRequest<Self>
}

public extension DatabaseEntity {
    static var fetch: NSFetchRequest<Self> { fetchRequest() }
}
