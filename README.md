# CoreDataCandy

Extensions and mapping on CoreData entities to provide **easy to use data models** and **fetching**.

## Why ?

Core Data is a great tool. Although, with the years, we felt some features were missing. You know, something more "Swifty", more declarative, easier to use. For instance, you do not want to write key paths as string to specify a property when fetching, you do not want to handle validation errors with `NSValidation` errors. This is what this library tries to solve: making Core Data even better by providing a range of tools to hide the inherent complexity of the framework.

#### Mapping

The first tool is a way to map a Core Data entity class, a `NSManagedObject` into a friendlier object - a `DatabaseModel`.  That' the mapping part. This protocol can be implemented by structures or classes and offers a way to declare the mapping: a field with validation, a relationship one to many with conversion (bye-bye NSSet!) or even publishers for an entity (holding a `NSFetchResultsController`). The goal is really to work with friendly faces, and to use the model editor as little as possible.

#### Fetching
The second tool this library has to offer is easy fetching. `NSPredicate`s and `NSSortDescriptor`s are very powerful, though not safe. You cannot know whether a request will fail and potentially cause a program exit before executing it. And mistakes happen, especially with strings. That is why the library will make it easier and safer to specify a predicate based on key paths, to specify a target when fetching, to specify a way to sort the data.

In a word, Core Data is powerful yet sometimes complex, so let's make it as sweet as candy.

## Overview
Before you dive into the [wiki](https://github.com/amaris/core-data-candy/wiki), you might to know what the words above mean. Here is a short overview.

Given an entity in a CoreData model:

```swift
class PlayerEntity: NSManagedObject {
    @NSManaged var name: String?
    @NSManaged var score: Int32
    @NSManaged var age: Int16
    @NSManaged var lastGame: Date?
    @NSManaged var avatar: Data?
}
```
It's possible to declare a mapping model `Player` to interface the entity with more friendly types, after having declared the conformance of `PlayerEntity` to `DatabaseEntity`.

```swift
extension PlayerEntity: DatabaseEntity {}

struct Player: DatabaseModel {

    public let _entityWrapper: EntityWrapper<PlayerEntity>
    
    let name = UniqueField(\.name, validations: .notEmpty)
    let score = Field(\.score) // Int
    let age = Field(\.age, validations: .isIn(18...24))
    let lastGame = Field(\.lastGame) //  Date?
    let avatar = Field(\.avatar, as: UIImage.self) // UIImage?
    
    init(entity: PlayerEntity) {
        _entityWrapper = .init(entity: entity)
        // perform additional code on the entity if needed
    }
}
```

Also, it's possible to use advanced fetching on both a Core Data `NSManagedObject` class or its associated `DatabaseModel` (here on the model).

```swift
Player.request()
    .first()
    .where(\.name == "Zerator")
    .feth(in: context) // output: Player?

Player.request()
    .all(after: 10)
    .where(\.age, .isIn(18...70))
    .sorted(by: .ascending(\.age), .descending\.name))
    .fetch(in: context) // output: [Player]
    
Player.request()
    .first(nth: 3)
    .where(\.name, .isIn("Zerator", "Mister MV", "Maghla")).or(\.age == 20)
    .setting(\.returnsDistinctResults, to: true) // set additional properties
    .fetch(in: context) // output: [Player]
```

**Notes**
- Storing a `UIImage` is done by making `UIImage` conform to `CodableConvertible` (which requires only the declaration). You can learn more in  the [advanced mapping section](https://github.com/amaris/core-data-candy/wiki/Advanced-Mapping).
- The `_entityrapper` property is a protocol requirement and is used to hide the entity once set, making it visible only internally in the API. That said, you are free to capture the `entity` reference in the initaliser to perform additional code.

## Wiki
We prefer a [wiki](https://github.com/amaris/core-data-candy/wiki) over a long Readme.

## Provided

- [A scheme of the architecture](Resources/CoreDataCandy-architecture.pdf)
