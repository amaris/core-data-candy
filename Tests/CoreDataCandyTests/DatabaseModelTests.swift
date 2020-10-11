//
// Copyright © 2018-present Amaris Software.
//

import XCTest
import Combine
import CoreData
@testable import CoreDataCandy

final class DatabaseModelTests: XCTestCase {

//    private var subscriptions = [AnyCancellable]()
//
//    func testAssign() throws {
//        let model = StubModel()
//        model.$property.validate = {
//            if $0 == "Yo" {
//                throw CoreDataCandyError.dataValidation(description: "That's impolite!")
//            }
//        }
//
//        try model.assign("Hello", to: \.$property)
//
//        XCTAssertEqual(model.property, "Hello")
//    }
//
//    func testValidateAssign_ValidateWrongValueThrows() throws {
//        let model = StubModel()
//        model.$property.validate = {
//            if $0 == "Yo" {
//                throw CoreDataCandyError.dataValidation(description: "That's impolite!")
//            }
//        }
//
//        XCTAssertThrowsError(try model.assign("Yo", to: \.$property))
//    }
//
//    func testValidateAssignWithPublisher() throws {
//        let model = StubModel()
//        model.$property.validate = {
//            if $0 == "Yo" {
//                throw CoreDataCandyError.dataValidation(description: "That's impolite!")
//            }
//        }
//
//        Just("Hello")
//            .tryAssign(to: \.$property, on: model)
//            .sink { completion in
//                if case .failure = completion {
//                    XCTFail()
//                }
//            } receiveValue: { (_) in }
//            .store(in: &subscriptions)
//    }
//
//    func testValidateAssignWithPublisher_ValidateWrongValueThrows() throws {
//        let model = StubModel()
//        model.$property.validate = {
//            if $0 == "Yo" {
//                throw CoreDataCandyError.dataValidation(description: "That's impolite!")
//            }
//        }
//
//        Just("Yo")
//            .tryAssign(to: \.$property, on: model)
//            .sink { completion in
//                guard case .failure = completion else {
//                    XCTFail()
//                    return
//                }
//            } receiveValue: { (_) in }
//            .store(in: &subscriptions)
//    }
}

extension DatabaseModelTests {

    final class StubEntity: NSManagedObject, DatabaseEntity {
        static func fetchRequest() -> NSFetchRequest<StubEntity> {
            NSFetchRequest<StubEntity>(entityName: "Stub")
        }

        var property = ""
        var imageData: Data?
        var color = NSObject()
    }

    struct StubModel: DatabaseModel {
        var entity = StubEntity()
        var context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)

        @Field(\.property, name: "property", validations: .notEmpty, .hasPrefix("Hello"))
        var property

        @Field(\.imageData, name: "", output: UIImage?.self)
        var image

        @Field(\.color, name: "", output: UIColor.self, default: .defaultTint)
        var color

        init(entity: StubEntity, context: NSManagedObjectContext) {}

        init() {}

        func tes() {

        }
    }
}


extension UIImage {
    static let template = UIImage()
}

extension UIColor {
    static let defaultTint = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
}
