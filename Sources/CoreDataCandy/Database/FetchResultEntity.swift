//
// Copyright © 2018-present Amaris Software.
//

import CoreData

/// Absract protocol to augment CoreData entities
public protocol FetchResultEntity: NSFetchRequestResult {
    static func fetchRequest() -> NSFetchRequest<Self>
}

public extension FetchResultEntity {
    static var fetch: NSFetchRequest<Self> { fetchRequest() }
}

/// Enitity in CoreData
public typealias DatabaseEntity = NSManagedObject & FetchResultEntity
