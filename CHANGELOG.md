# CoreDataCandy

All notable changes to this project will be documented in this file. `CoreDataCandy` adheres to [Semantic Versioning](http://semver.org).

---
## [0.3.0](https://github.com/amaris/core-data-candy/tree/0.3.0) (21/01/2021)

### Added
- Fallback value before `preconditionFailure` when converting stored value
- Store conversion error publisher
- Map current functions on `DatabaseModel` collections

### Changed
- `DatabaseFieldValue` now `Equatable`
- `PredicateRightValue` public init
- `DatabaseModel` extensions functions moved in the protocol declaration to make them customisation points.

## [0.2.2](https://github.com/amaris/core-data-candy/tree/0.2.2) (04/12/2020)

### Fixed
- `DatabaseModel.remove` useless `throws` deleted [#18]

## [0.2.1](https://github.com/amaris/core-data-candy/tree/0.2.1) (23/11/2020)

### Fixed
- `Validation.init` now public

## [0.2.0](https://github.com/amaris/core-data-candy/tree/0.2.0) (20/11/2020)

### Added
- `Codable` to store a custom type
- `CodableConvertible` to store a type with an intermediate `Codable` object. Default implementation for `NSObject`s
- Multiple sorts when subscribing to an entity relationship [#2]

### Changed
- Fetching now uses a `RequestBuilder` to specify a request
- `ComparisonPredicate` and `OperatorPredicate` have been merged into a single `Predicate` structure.
- The store conversion with an entity attribute will now exit the program if it fails rather than throwing an error
- `FetchableEntity` has been deleted to keep only `DatabaseEntity`
- Compound predicate 'and' and 'or' now use the `NSCompoundPredicate` class rather than raw values.

## [0.1.1](https://github.com/amaris/core-data-candy/tree/0.1.1) (04/11/2020)

### Fixed
- Operator predicates with second generic type

## [0.1.0](https://github.com/amaris/core-data-candy/tree/0.1.0) (04/11/2020)

Initial release.
