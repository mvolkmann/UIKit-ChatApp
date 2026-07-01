import Foundation

let ME = "Me"

struct Message {
    let from: String
    let to: String
    let text: String
    let sent_at: Foundation.Date

    func isFromMe() -> Bool { from == ME }
}

protocol ModelDelegate {
    func onContactsChanged()
}

class Model {
    var delegate: ModelDelegate?
    // The names of our contacts.
    private var contacts: [String]
    private var threads: [String: [Message]]

    init(contacts: [String] = [], threads: [String: [Message]] = [:]) {
        self.contacts = contacts
        self.threads = threads
    }

    func getAllThreads() -> [String] {
        return contacts
    }

    func addContact(newContact: String) {
        contacts.append(newContact)
        threads[newContact] = [Message]()
        delegate?.onContactsChanged()
    }

    func addMessage(_ message: Message) {
        let contact = message.from == ME ? message.to : message.from
        threads[contact]?.append(message)
    }

    func getMessages(forContact: String) -> [Message] {
        return threads[forContact] ?? []
    }

    // RMV
    static func sampleData() -> Model {
        let model = Model()
        model.addContact(newContact: "Tester")
        model.addMessage(Message(
            from: "Tester",
            to: ME,
            text: "Hello",
            sent_at: Date(timeIntervalSince1970: 0)
        ))
        model.addMessage(Message(
            from: ME,
            to: "Tester",
            text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque finibus, metus id blandit tincidunt, ligula dolor convallis purus, eget efficitur arcu lectus non risus. Nunc dictum massa vel quam aliquet tincidunt.",
            sent_at: Date(timeIntervalSince1970: 1)
        ))
        return model
    }

    // RMV
    func sendMessage(to contact: String, text: String) {
        addMessage(Message(
            from: ME,
            to: contact,
            text: text,
            sent_at: Date()
        ))
    }
}
