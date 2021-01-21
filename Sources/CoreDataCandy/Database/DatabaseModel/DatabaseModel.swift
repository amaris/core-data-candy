//
// CoreDataCandy
// Copyright © 2018-present Amaris Software.
// MIT license, see LICENSE file for details

import CoreData
import Combine

/// Holds a CoreData entity and hide the work with the CoreData context while offering Swift types to work with
public protocol DatabaseModel: Fetchable, Hashable, CustomDebugStringConvertible {

    // MARK: - Constants

    associatedtype Entity: DatabaseEntity

    // MARK: - Properties

    /// This wrapper will be used internally by the API and cannot be used outside.
    /// Its purpose is to hide the `entity` from the rest of the app.
    /// The only requirement is to instantiate it in the  `init(entity:)` initializer.
    var _entityWrapper: EntityWrapper<Entity> { get }

    // MARK: - Initialisation

    /// Instantiate the `DatabaseModel`. It's the oppurtinity to perform
    /// some code on the `entity` if needed, as the `entity` will then be hidden
    /// behind the `_entityWrapper`
    init(entity: Entity)

    // MARK: - Functions

    // MARK: Field interface

    /// The current value of the given field
    func current<F: FieldInterfaceProtocol>(_ keyPath: KeyPath<Self, F>) -> F.Value
    where F.Entity == Entity

    /// The current value of the given optional field flattened to an optional
    func current<F: FieldInterfaceProtocol>(_ keyPath: KeyPath<Self, F>) -> F.Value
    where F.Entity == Entity, F.FieldValue: ExpressibleByNilLiteral, F.Value: ExpressibleByNilLiteral

    // MARK: Field modifier

    /// Validate the value for the given field property, throwing a relevant error if the value is invalidated
    func validate<F: FieldModifier>(_ value: F.Value, for keyPath: KeyPath<Self, F>) throws
    where F.Entity == Entity

    /// Assign the value to the given field property
    func assign<F: FieldModifier>(_ value: F.Value, to keyPath: KeyPath<Self, F>)
    where F.Entity == Entity

    /// Validate the value for the given field property then assign it, throwing a relevant error if the value is invalidated
    func validateAndAssign<F: FieldModifier>(_ value: F.Value, to keyPath: KeyPath<Self, F>) throws
    where F.Entity == Entity

    /// Toggle the boolean at the given key path
    func toggle<F: FieldInterfaceProtocol>(_ keyPath: KeyPath<Self, F>)
    where F.Value == Bool, F.Entity == Entity

    // MARK: Field publisher

    /// Publisher for the given field
    func publisher<F: FieldPublisher>(for keyPath: KeyPath<Self, F>) -> AnyPublisher<F.Output, Never>
    where F.Entity == Entity

    // MARK: Children

    /// Current value of the one-to-many relationship
    func current<Children: ChildrenInterfaceProtocol>(_ keyPath: KeyPath<Self, Children>)
    -> [Children.ChildModel]
    where Children.Entity == Entity

    /// Add a child to the one-ton-many relationship
    func add<Children: ChildrenInterfaceProtocol>(_ child: Children.ChildModel, to childrenKeyPath: KeyPath<Self, Children>)
    where Children.Entity == Entity

    /// Remove a child from the one-ton-many relationship
    func remove<Children: ChildrenInterfaceProtocol>(_ child: Children.ChildModel, to childrenKeyPath: KeyPath<Self, Children>)
    where Children.Entity == Entity

    /// Insert a child at the specified index to the ordered one-ton-many relationship
    func insert<ChildModel: DatabaseModel>(_ child: ChildModel, at index: Int, in childrenKeyPath: KeyPath<Self, OrderedChildren<ChildModel>>) throws

    /// Remove a child  at the specified index to the ordered one-ton-many relationship
    func remove<ChildModel: DatabaseModel>(at index: Int, in childrenKeyPath: KeyPath<Self, OrderedChildren<ChildModel>>) throws

    /// Publisher for the given relationship
    /// - Parameters:
    ///   - keyPath: The children to observe
    ///   - sorts: Sorts to be applied to the emitted array
    /// - Returns: An array of the children
    ///
    /// ### Examples
    ///  - `publisher(for: \.children, sortedBy: .ascending(\.property))`
    ///  - `publisher(for: \.children, sortedBy: .descending(\.date), .ascending(\.name))`
    ///
    func publisher<F: FieldPublisher & ChildrenInterfaceProtocol>(
        for keyPath: KeyPath<Self, F>,
        sortedBy sorts: Sort<F.ChildModel.Entity>...)
    -> AnyPublisher<F.Output, Never>
    where F.Entity == Entity, F.Output == [F.ChildModel]

    // MARK: Parent

    /// Current value for the given parent's field
    func current<P: ParentInterfaceProtocol, F: FieldInterfaceProtocol>(_ parentKeyPath: KeyPath<Self, P>, _ valueKeyPath: KeyPath<P.ParentModel, F>)
    -> F.Value?
    where P.Entity == Entity, F.Entity == P.ParentModel.Entity

    /// Current value for the given parent's field
    func current<P: ParentInterfaceProtocol, F: FieldInterfaceProtocol>(_ parentKeyPath: KeyPath<Self, P>, _ valueKeyPath: KeyPath<P.ParentModel, F>)
    -> F.Value
    where P.Entity == Entity, F.Entity == P.ParentModel.Entity, F.Value: ExpressibleByNilLiteral

    /// Get the current parent of the model
    func current<P: ParentInterfaceProtocol>(_ keyPath: KeyPath<Self, P>)
    -> P.ParentModel?
    where P.Entity == Entity

    // MARK: Fetch update

    /// Publisher for the entity table updates in Core Data using a `NSFetchedResultsController`
    /// - Parameters:
    ///   - sort: Required sort
    ///   - additionalSorts: Additional sorts
    ///   - request: A request to use rather than the default one
    ///   - context: The context where to fetch
    /// - Returns: An array of the published models
    static func updatePublisher(
        sortingBy sort: SortDescriptor<Entity>,
        _ additionalSorts: SortDescriptor<Entity>...,
        for request: NSFetchRequest<Entity>?,
        in context: NSManagedObjectContext?)
    -> AnyPublisher<[Self], Never>

    // MARK: Delete

    /// Delete the model entity from its context
    func remove()
}

extension DatabaseModel {

    var entity: Entity { _entityWrapper.entity }
}

public extension DatabaseModel {

    func remove() {
        let context = entity.managedObjectContext
        context?.delete(entity)
    }
}

// MARK: - Hashable

public extension DatabaseModel {

    func hash(into hasher: inout Hasher) {
        hasher.combine(entity)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.entity == rhs.entity
    }
}

// MARK: - Description

extension DatabaseModel {

    /// Textual representation of the entity attributes
    public var debugDescription: String {
        let entityDescription = entity.description

        guard let range = entityDescription.range(of: #"\{(.|\s)+\}"#, options: .regularExpression) else {
            return "Fault data"
        }

        return String(describing: Self.self) + " " + entityDescription[range]
    }
}
