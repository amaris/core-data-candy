# CoreDataCandy

Extensions and mapping on CoreData entities to provide **easy to use data models** and **fetching**.

### Provided

- [A scheme of the architecture](Resources/CoreDataCandy-architecture.pdf)

### Overview
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

Also, it's possible to use advanced fetching.

```swift
Player.request()
    .first()
    .where(\.name == "Zerator")
    .feth(in: context) // output: Player?

Player.request()
    .all(after: 10)
    .where(\.age, .isIn(18...70))
    .sorted(by: \.age)
    .then(by: \.name)
    .fetch(in: context) // output: [Player]
    
Player.request()
    .first(nth: 3)
    .where(\.name, .isIn("Zerator", "Mister MV", "Maghla"))
        .or(\.age == 20)
    .setting(\.returnsDistinctResults, to: true) // set additional properties
    .fetch(in: context) // output: [Player]
```

**Notes**
- Storing a `UIImage` is done by making `UIImage` conform to `Codable`. You can learn more in  the [advanced mapping section](#advanced-mapping).
- The `_entityrapper` property is a protocol requirement and is used to hide the entity once set, making it visible only internally in the API. That said, you are free to capture the `entity` reference in the initaliser to perform additional code.

## Core Data entity mapping

### Reading

#### Current value

To read a current value in the database model, you can call its `current(:)` function. This allows to read a field, a parent value or a child value when exposed by the related model. 
Given the following `Game` entity, Here are some examples.

```swift
class PlayerEntity: NSManagedObject {
    @NSManaged var games: NSSet?
}

class GameEntity: NSManagedObject {
    @NSManaged var duration: Double
    @NSManaged var player: PlayerEntity?
}
```

```swift
let player: Player
let gameEntity: Game

player.current(\.name) // String?
player.current(\.score) // Double
player.current(\.avatar) // UIImage?
player.current(\.games) // [Game]

game.current(\.player, \.name) // String?
game.current(\.score) // Double
```

#### Published value

You can also subscribe to a value rather than reading it.

```swift
let player: Player

func setupSubscriptions() {
    player.publisher(for: \.name)
        .assign(to: name.label.text, on self)
        
    player.publisher(for: \.avatar)
        .assign(to: avatarView.image, on: self)
}
```

### Writing
To set the `Player` value, you can either use the `assign(:to:)` function or the publisher `assign(to:on:)` when using a publisher that emits the value to assign. 

```swift
player.assign(newName, to: \.name)

Just(newName)
    .assign(to: \.name, on: player)
    .sink(receiveCompletion:  { completion in
    //...
    }, receiveValue: { _ in })
```

#### Validating

Before assigning a value, you can validate it with the `validate(:for:)` function or the publisher `tryValidate(for:on)`.

```swift
try player.validate(newName, for: \.name)

Just(newName)
    .validate(for: \.name, on: player)
    .sink(receiveCompletion:  { completion in // can finish with a failure
    //...
    }, receiveValue: { _ in })
```

Optionally, you can use the `validateAndAssign(:to:)`function or the `tryValidateAndAssign(to:on:)` publisher.

```swift
try player.validateAndassign(newName, to: \.name)

Just(newName)
    .tryValidateAndAssign(to: \.name, on: player)
    .sink(receiveCompletion:  { completion in // can finish with a failure
    //...
    }, receiveValue: { _ in })
```


### Relationships

To map a relationship between two entities, you can use:
- `Children` to map a **1:N** relationship (from the parent point of view)
- `OrderedChildren` to map an ordered **1:N** relationship (from the parent point of view)
- `Parent` to map a **N:1** relationship (from the child point of view)
- `Sibling` to map a **1:1** relationship (from the child point of view)

For example, if the player entity has a **1:N** relationship with a `GameEntity` entity mapped with a `Game` model, you can declare 

```swift
let games = Children(\.games, as: Game.self)
```
It's then possible to use the publisher `player.publisher(for: \.games)` which will emit a `Game` array, or to call relevant modifications CRUD functions.

```swift
// Subscribe to the player games, sorted by their date
player.publisher(for: \.games, sortedBy: .ascending(\.date))

// Add a `Game` model to the player `games` relationship
let game = Game(...)
try player.add(game, to: \.games)
```

Also, as the context saving can throw, you have the handle this `CoreDataCandyError.unableToSaveContext` error if you want to perform a relevant action.

### NSFetchedResultsController

Once a `DatabaseModel` is declared to map an entity, you can subscribe to its fetched results updates with the static `updatePublisher(sortingBy:)` function. The subscription will hold a `NSFetchedResultsController` and the emitted values will be an array of `DatabaseModel`.

```swift
Player.updatePublisher(sortedBy: \.ascending(.name)) // emits [Player]
```

When working with a [diffable data source](https://developer.apple.com/wwdc19/220), this can be really useful, especially as a `DatabaseModel` is hashable.

### Advanced mapping

#### Default values

It's possible to declare default values that should be used if the stored value is `nil`. Doing so transform the output type as non optional.

```swift
let name = Field(\.name, default: "John") // output: String
let avatager = Field(\.avatar, as: UIImage, default: .placeholder) // output: UIImage
```

#### Unique field

This declaration ensures the unicity of the entity attribute in the entity table. Each time an `assign(:to:)` function is called, a fetch will be performed to make sure the value is not already used.

```swift
let name = UniqueField(\.name)
```

#### Codable

You can store a `Codable` object as data. to do so, set the value type of the attribute as data, then declare the type with the field.

```swift
let avatar = Field(\.avatar, as: UIImage.self)
```
The library will automatically try to encode and decode the value to store it as binary data. You can then choose how to encode and decode your custom type. for example with `UIColor` by storing its red, green , and blue component in a struct (it's already quite an example to show you how it's possible to work with `NSObject`. It goes without saying that storing simple `Codable` struct would be easier) :

```swift
struct StoreColor: Codable {
    let red: Double
    let green: Double
    let blue: Double
}

extension UIImage: Codable {

    enum StoreCodingKeys: CodingKey {
        case storeColor
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.contained(keyedBy: StoreCodingKeys.self)
        let storeColor = try container.decode(StoreColor.Self, for: .storeColor)
        self.init(with: storeColor)
    }
    
    func encode(to encoder: Encoder) throws {
        let container = try encoder.container(keyedBy: StoreCodingKeys.self)
        try container.encode(storeColor, for: .storeColor)
    }
}       
```
**⚠️ Coding error**

If an error is encountered when encoding or decoding, a `preconditionFailure` will be used to terminate immediately. This is an implementation design choice. We consider than storing a value which cannot be converted to a desired type should be resolved in the development stage, and is not relevant for the end-user.

### Validation

When declaring a field, you can add one or more validations on the received value. All the validations will be evaluated when trying to assign using `assign(:to:)`, and an error will be thrown if the value is not validated.

To use a validation, you can simply declare it. A validation is available when it makes sense for the value type (.e.g. `isEmail` is only for String values).

```swift
// name: String?
let name = Field(\.name, validations: .notEmpty)
let name = Field(\.name, validations: .hasPrefix("Do"))
let name = Field(\.name, validations: .hasPrefix("Do"), .contains("remi"))

// score: Double
let score = Field(\.score, validations: .range(100...1000))
```

Other validations will be added in the future. Meanwhile, you can add your own validation, for example, to make sure a numeric value is greater than a given threshold:

```swift
extension Validation where Value: Numeric & Comparable {

    static func greaterThan(_ value: Value) -> Self {
        Validation {
            if value <= $0 {
                throw CoreDataCandyError.dataValidation(description: "Value \($0) is greater than \($0)")
            }
        }
    }
}
```

#### List
Here is the exhaustive list of currently available validations:
- String: `notEmpty`, `hasSuffix`, `hasPrefix`, `contains`, `doesNotContain`, `count`, `isEmail`
- Numeric & Comparable: `isIn`, `greaterThan`, `greaterThanOrEqualTo`, `lesserThan`, `lesserThanOrEqualTo`
- ExpressibleByNilLiteral: `notNil`

---
## Fetchable

This library also offers simple way to fetch objects. The only requirement to use those fetch functions is to declare the conformance of your Core Data entity to `FetchableEntity`:

```swift
extension PlayerEntity: FetchableEntity {}
```

### Provide the context

When executing a request, you have the provide the context where the request should be executed. To not pass a `context` parameter each time you call the fetch function, you can optionally specify a default `context` to be used for fetching within a `Fetchable` extension.

```swift
extension Fetchable {
    var context: NSManagedObjectContext? { /** return your app view context */ }
}
```

You can then either fetch the entity directly, or fetch its `DatabaseModel` if you declared one. For the examples, we will use the  `DatabaseModel` and assume that a default context is provided.

### Fetch target

You can specify a target when fetching.

```swift
// fetch all player entities (mapped with the 'Player' database model)
Player.request().all().fetch() // output: [Player]

// fetch the first player entity (mapped with the 'Player' database model)
Player.request().first().fetch() // output: Player?

// fetch the first 10th player entities (mapped with the 'Player' database model)
Player.request().first(nth: 10).fetch() // output: [Player]
```

### Predicate

You can specify a predicate on a single attribute when fetching. When comparing the value, you can use the comparison operator with no comma. For advanced operators, a comma between the KeyPath and the operator is required.

```swift
Player.request()
    .first()
    .where(\.name == "Zerator")

Player.request()
    .first()
    .where(\.name, .hasPrefix("Z"))

Player.request()
    .all()
    .where(\.age >= 20)
    
Player.request()
    .all()
    .where(\.score, .isIn(1000...5000))
    
Player.request()
    .first(nth: 10)
    .where(\.name, .isIn("Zerator", "Mister MV", "Maghla"))
```

If needed, you can use compound predicates.

```swift
Player.request()
    .first()
    .where(\.name == "Zerator").or(\.name == "Mister MV")
        
Player.request()
    .all()
    .where(\.age >= 20).and(\.name, .hasSuffix("ra")).or(\.score < 20)
```

### Sorting

Pass one or several sorts when fetching.

```swift
Player.request()
    .all()
    .where(\.age >= 20)
    .sorted(by: .ascending, \.score)

Player.request
    .all()
    .where(\.name, isIn: ["Zerator", "Mister MV", "Maghla"])
    .sorted(by: .descending, \.age).then(by: .ascending, \.name)
```

### Additional settings
To be written

## Exhaustive lists

### Field predicate
#### Comparison predicates
`==`, `<`,`<=`, `>`, `>=`

#### Specific operator predicates
##### Equatable
`isIn(:)`, `isNot(in:)` to filter the value if contained in the given array or variadic values

##### String
`hasPrefix`, `hasNoPrefix`, `hasSuffix`, `contains`, `doesNotContain`, and `matches`(a regular expression)
and their opposites:
`hasNoPrefix`, `hasNoSuffix`, `doesNotContain`, and `doesNotMatch`

##### Comparable
`isIn` to filter the value if contained in a range (closed or half-open) and `isNotIn`.
