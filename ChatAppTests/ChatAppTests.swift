@testable import ChatApp
import XCTest

final class ChatAppTests: XCTestCase {
    var model: Model!

    override func setUpWithError() throws {
        model = Model()
    }

    override func tearDownWithError() throws {}

    func test_GetAllThreads_ReturnsThreadsForEachContact() throws {
        // ARRANGE
        model.addContact(newContact: "Al")
        // ACT
        let openThreads = model.getAllThreads()
        // ASSERT
        XCTAssert(openThreads.count == 1)
        XCTAssert(openThreads.first! == "Al")
    }

    func test_AddContact() throws {
        // ARRANGE

        // ACT
        model.addContact(newContact: "Mike")
        let allThreads = model.getAllThreads()
        // ASSERT
        XCTAssert(allThreads.count == 1)
        XCTAssert(allThreads[0] == "Mike")
    }

    func test_GetMessagesForContact_ReturnsTheThreadBetweenUs() throws {
        model.addContact(newContact: "Tester")
        model.addMessage(Message(
            from: "Tester",
            to: "Me",
            text: "Hi",
            sent_at: Date(timeIntervalSince1970: 0)
        ))

        let messages = model.getMessages(forContact: "Tester")

        XCTAssert(messages.count == 1)
        XCTAssert(messages[0].text == "Hi")
    }

    func test_GetMessagesForContact_EmptyState() throws {
        model.addContact(newContact: "Tester")

        let messages = model.getMessages(forContact: "Tester")

        XCTAssert(messages.count == 0)
    }

    func test_GetMessagesForContact_WhenNoContact() throws {
        model.addMessage(Message(
            from: "Tester",
            to: "Me",
            text: "Hi",
            sent_at: Date(timeIntervalSince1970: 0)
        ))

        let messages = model.getMessages(forContact: "Tester")

        XCTAssert(messages.count == 0)
    }

    // RMV
    func test_SampleData_ReturnsTesterThreadWithMessages() throws {
        let sampleModel = Model.sampleData()

        let threads = sampleModel.getAllThreads()
        XCTAssertEqual(threads, ["Tester"])

        let messages = sampleModel.getMessages(forContact: "Tester")
        XCTAssertEqual(messages.count, 2)

        XCTAssertEqual(messages[0].from, "Tester")
        XCTAssertEqual(messages[0].to, ME)
        XCTAssertEqual(messages[0].text, "Hello")
        XCTAssertEqual(messages[0].sent_at, Date(timeIntervalSince1970: 0))

        XCTAssertEqual(messages[1].from, ME)
        XCTAssertEqual(messages[1].to, "Tester")
        XCTAssertTrue(messages[1].text.hasPrefix("Lorem ipsum"))
        XCTAssertEqual(messages[1].sent_at, Date(timeIntervalSince1970: 1))
    }

    // RMV
    func test_SendMessage_AddsMessageFromMeToContact() throws {
        let contact = "Samuel"
        model.addContact(newContact: contact)
        let beforeSend = Date()

        model.sendMessage(to: contact, text: "Hi there")
        let afterSend = Date()
        let messages = model.getMessages(forContact: contact)

        XCTAssertEqual(messages.count, 1)
        XCTAssertEqual(messages[0].from, ME)
        XCTAssertEqual(messages[0].to, contact)
        XCTAssertEqual(messages[0].text, "Hi there")
        XCTAssertGreaterThanOrEqual(messages[0].sent_at, beforeSend)
        XCTAssertLessThanOrEqual(messages[0].sent_at, afterSend)
    }
}
