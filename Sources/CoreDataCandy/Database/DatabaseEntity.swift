//
// Copyright © 2018-present Amaris Software.
//

import CoreData
import Combine

/// Entity in CoreData
public protocol DatabaseEntity: Hashable {
    var managedObjectContext: NSManagedObjectContext? { get }

    init(context moc: NSManagedObjectContext)
}
