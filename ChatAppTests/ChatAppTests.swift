import XCTest
@testable import ChatApp

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
		//ARRANGE
		
		//ACT
		model.addContact(newContact: "Mike")
		let allThreads = model.getAllThreads()
		//ASSERT
		XCTAssert(allThreads.count == 1)
		XCTAssert(allThreads[0] == "Mike")
	}

	func test_GetMessagesForContact_ReturnsTheThreadBetweenUs() throws {
		model.addContact(newContact: "Tester")
		model.addMessage(Message(from: "Tester", to: "Me", text: "Hi", sent_at: Date(timeIntervalSince1970: 0)))
		
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
		model.addMessage(Message(from: "Tester", to: "Me", text: "Hi", sent_at: Date(timeIntervalSince1970: 0)))
		
		let messages = model.getMessages(forContact: "Tester")
		
		XCTAssert(messages.count == 0)
	}

//	func test_SendMessageToContact() throws {
//		XCTAssert(false)
//	}
}
