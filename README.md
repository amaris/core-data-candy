# CoreDataCandy

Extensions and mapping on CoreData entities to provide **easy to use data models** and **fetching**.

### Provided

- [A scheme of the architecture](Resources/CoreDataCandy-architecture.pdf)

## Core Data entity mapping

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
    let name = UniqueField(\.name, validations: .notEmpty) // ensure the unicity of the 'name' attribute
    let score = Field(\.score) // Int
    let age = Field(\.age, validations: .isIn(18...24)
    let lastGame = Field(\.lastGame) //  Date?
    let avatar = Field(\.avatar, as: UIImage.self) // UIImage?
}
```

**Note**: Storing a `UIImage` is done by making `UIImage` conform to `Codable`. You can learn more in  the [advanced mapping section](#advanced-mapping)

### Reading

#### Current value

To read a current value in the database model, you can call its `current(:)` function. This allows to read a field, a parent value or a child value when exposed by the model. When the targeted property is a [custom storage type](#advanced-mapping), the `current(:)` function can throw.
Given the following `Game` entity, Hera are some examples.

```swift
class PlayerEntity: NSManagedObject {
    @NSManaged var games: NSSet?
}

class GameEntity: NSManagedObject {
    @NSManaged var duration: Double
    @NSManaged bar player: PlayerEntity?
}
```

```swift
let player: Player
let gameEntity: Game

player.current(\.name) // String?
player.current(\.score) // Double
try player.current(\.avatar) // UIImage?
player.current(\.games) // [Game]

game.current(\.player, \.name) // String?
game.current(\.score) // Double
```

#### Published value

To use this model, you can subscribe to its publisher. When a custom storage type  has to be decoded (e.g. `avatar`), the publisher can send an error completion.

```swift
let player: Player

func setupSubscriptions() {
    player.publisher(for: \.name)
        .assign(to: name.label.text, on self)
        
    player.publisher(for: \.avatar)
        .replaceError(with: .placeholder)
        .assign(to: avatarView.image, on: self)
}
```

As `player.publisher(for: \.avatar)` can emit an error when transforming the `Data` to a `UIImage`, you have to handle the error, for example here by providing a default `UIImage.placeholder`. Note that this is also possible to have this default image when declaring the `avatar` field:

```swift
let avatar = Field(\.avatar, as: UIImage.self, default: .placeholder) // output: UIImage
```

### Writing
To set the `Player` value, you can either use the `assign` function or the publisher `tryAssign` when using a publisher that emits the value to assign. Those calls can throw because of the validation. This allows to show a relevant message to the user when the validation throws an error.

```swift
try player.assign(newName, to: \.name)

player.tryAssign(newName, to: \.name)
    .sink(receiveCompletion:  { completion in // can throw when the name is empty
        if case let .failure(error) = completion {
            // show an alert to the user
        }
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

Once a `DatabaseModel` is declared to map an entity, you can subscribe to its fetched results updates with the static `updatePublisher(sortingBy:)`. The subscription will hold a `NSFetchedResultsController` and the emitted values will be an array of `DatabaseModel`.

```swift
Player.updatePublisher(sortedBy: \.ascending(.name)) // emits [Player]
```

When working with a [diffable data source](https://developer.apple.com/wwdc19/220), this can be really useful, especially as a `DatabaseModel` is hashable.

### Advanced mapping
#### Optional

You can specify that an attribute stored as an optional (e.g. a `String?`) should be unwrapped with the `Field(unwrapped:)` initialiser. In this case, the publisher will send an error if the optional is `nil`.

```swift
let name = Field(unwrapped: \.name)
```

#### Codable

You can store a `Codable` object as data. to do so, set the value type of the attribute as data, then declare the type with the field.

```swift
let avatar = Field(\.avatar, as: UIImage.self)
```
The library will automatically try to encode and decode the value to store it as binary data. You can then choose how to encode and decode your custom type. for example with `UIColor` by storing its red, green , and blue component in a struct (it's already quite an example to show you how it's possible to work with `NSObject`. It goes without saying that storing simple `Codable` struct would be way easier) :

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

### Validation

When declaring a field, you can add one or more validations on the received value. All the validations will be evaluated when trying to assign using `assign(:to:)`, and an error will be thrown if the value is not validated.

To use a validation, you can simply declare it. A validation is available when it makes sense for the value type.

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

When building a request you have the provide the context where to fetch when calling the final function `fetch(:)` which will execute it. To not pass a `context` parameter when fetching, you can optionally specify a default `context` to be used for fetching within a  `Fetchable` extension.

```swift
extension Fetchable {
    var context: NSManagedObjectContext? { /** return your app view context */ }
}
```

You can then either fetch the entity directly, or fetch its mapping database model if you declared one. For the examples, we will use the database model and assume that a default context is provided.
For the examples, we will use the database model and assume that a default context is provided.

### Fetch target

You can specify a target when fetching.

```swift
// fetch all player entities (mapped with a database model)
Player.request().all().fetch() // output: [Player]

// fetch the first player entity (mapped with a database model)
Player.request().first().fetch() // output: Player?

// fetch the first 10th player entities (mapped with a database model)
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
    .where(\.name, hasPrefix("Z"))

Player.request()
    .all()
    .where(\.age >= 20)
    
Player.request()
    .all()
    .where(\.score, isIn: 1000...5000))
    
Player.request()
    .first(nth: 10)
    .where(\.name, isIn: "Zerator", "Mister MV", "Maghla"))
```

If needed, you can use compound predicates.

```swift
Player.request()
    .first()
    .where(\.name == "Zerator")
        .or(\.name == "Mister MV")
        
Player.request().
    all()
    .where(\.age >= 20)
        .and(\.name, .hasSuffix("ra")
        .or(\.score < 20)
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
    .sorted(by: .descending, \.age)
        .then(by: .ascending, \.name)
```

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
