# CoreDataCandy

Extensions and mapping on CoreData entities to provide **easy to use data models** and **fetching**.

### Provided

- [A scheme of the architecture](Resources/CoreDataCandy-architecture.pdf)

## Core Data entity mapping

Given an entity in a CoreData model:

```swift
class PlayerEntity: NSManagedObject {

	@NSManaged var name: String?
	@NSManaged var score: Int32
	@NSManaged var age: Int16
	@NSManaged var lastGame: Date?
	@NSManaged var avatar: Data
}
```
It's possible to declare a mapping model `Player` to interface the entity with more friendly types, after having declared the conformance of `PlayerEntity` to `DatabaseEntity`.

```swift
extension PlayerEntity: DatabaseEntity {}

struct Player: DatabaseModel {
	let name = UniqueField(\.name, validations: .notEmpty) // ensure the unicity of the 'name' attribute
	let score = Field(\.score) // output type: Int
	let age = Field(\.age, validations: .range(18...24)
	let lastGame = Field(unwrapped: \.lastGame) // output type: Date
	let avatar = Field(\.avatar, output: UIImage.self) // output type: UIImage
}
```

### Reading

To use this model, you can subscribed to its publisher. When an optional as to be unwrapped (e.g. `lastGame`, or a store type has to be transformed (e.g. `avatar`), the publish can send an error completion.

```swift
let player = Player()

func setupSubscriptions() {
	player.publisher(for: \.name)
		.assign(to: name.label.text, on self)
		
	player.publisher(for: \.avatar)
		.replaceError(with: .placeholder)
		.assign(to: avatarView.image, on: self)
}
```

As `player.publisher(for: \.avatar)` can emit an error when transforming the `Data` to a `UIImage`, you have to handle the error, for example here by providing a default `UIImage.placeholder`. Note that it is also possible to have this default image when declaring the `avatar` field:

```swift
let avatar = Field(\.avatar, output: UIImage.self, default: .placeholder) // replace the error with a default placeholder image
```

### Writing
To set the `Player` value, you can either use the `assign` function or the publisher `tryAssign` when using a publisher that emits the value to assign. Those calls wan throw because of the validation. This allows to show a relevant message to the user when the validation throws an error.

```swift
	try player.assign(newName, to: \.name)
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

For example, if the player entity has a **1:N** relationship with a `games` `GameEntity` mapped with a `Game`, you can declare 

```swift
let games = Children(\.games, as: Game.self)
```
It's then possible to use the publisher `player.publisher(for: \.games)` which will emit a `Game` array, or to call relevant modifications functions like

```swift
let game: Game

player.add(game, to: \.games)
```

Also, as the context saving can throw, you have the handle this `CoreDataCandyError.unableToSaveContext` error if you want to perform a relevant action.

### Advanced mapping

#### Optionals

#### DataConvertible and NSObjectConvertible

#### Validation

## Fetchable

This library also offers simple way to fetch objects. The only requirement to use those fetch functions is to declare the conformance of your Core Data entity to `FetchableEntity`:

```swift
extension PlayerEntity: FetchableEntity {}
```

Then, you can either fetch the entity directly, or fetch its mapping database model:

```swift
let context: NSManagedObjectContext
	
PlayerEntity.fetch(..., in: context: context)
Player.fetch(..., in: context)
```

To not pass a `context` parameter when fetching, you can optionally specify a default `context` to be used for fetching within a  `Fetchable` extension.

```swift
extension Fetchable {
	var context: NSManagedObjectContext? { /** return your app view context */ }
}
```

For the examples, we will use the database model and assume that a default context is provided.

### Fetch target

You can specify a target when fetching.

```swift
// fetch all player entities (mapped with a database model)
Player.fetch(.all()) // output: [Player]

// fetch the first player entity (mapped with a database model)
Player.fetch(.first()) // output: Player?

// fetch the first 10th player entities (mapped with a database model)
Player.fetch(.first(nth: 10)) // output: [Player]
```

### Predicate

You can specify a predicate on a single attribute when fetching. When comparing the value, you can use the comparison operator with no comma. For advanced operators, a comma between the KeyPath and the operator is required.

```swift
Player.fetch(.first(), where: \.name == "Zerator")
Player.fetch(.first(), where: \.name, .hasPrefix("Z"))
Player.fetch(.all(), where: \.age >= 20)
Player.fetch(.all(), where: \.score, .isIn(1000...5000))
Player.fetch(.first(nth: 10), where: \.name, .isIn("Zerator", "Mister MV", "Maghla")
```

### Sorting

Pass one or several sorts when fetching.

```swift
Player.fetch(.all(), where: \.age >= 20, sortedBy: .ascending(\.score))
Player.fetch(.all(),
			 where: \.name, .isIn(["Zerator", "Mister MV", "Maghla"],
			 sortedBy: .descending(\.age), .ascending(\.name))
```

## Exhaustive lists

### Field validations

### Fetching predicate operators