//
//  ViewController.swift
//  ChatApp
//
//  Created by mlcmc on 7/1/25.
//

import UIKit

// MARK: ContactsVC -

class ContactsVC: UIViewController, ModelDelegate {
	@IBOutlet weak var tableView: UITableView!
	var model: Model!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		model = Model()
		model.delegate = self
		tableView.delegate = self
		tableView.dataSource = self
		
		model.addContact(newContact: "Tester")
		model.addMessage(Message(from: "Tester", to: ME, text: "Hello", sent_at: Date(timeIntervalSince1970: 0)))
		model.addMessage(Message(from: ME, to: "Tester", text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque finibus, metus id blandit tincidunt, ligula dolor convallis purus, eget efficitur arcu lectus non risus. Nunc dictum massa vel quam aliquet tincidunt.", sent_at: Date(timeIntervalSince1970: 1)))
	}
	
	@IBAction func addContactPressed(_ sender: Any) {
		let alert = UIAlertController(title: "Add New Contact", message: nil, preferredStyle: .alert)
		alert.addTextField()
		alert.addAction(.init(title: "Save", style: .default, handler: { action in
			let contactName = alert.textFields![0].text ?? ""
			if !contactName.isEmpty {
				self.model.addContact(newContact: contactName)
			}
		}))
		alert.addAction(.init(title: "Cancel", style: .destructive))
		self.present(alert, animated: true)
	}
	
	func onContactsChanged() {
		tableView.reloadData()
	}
}

extension ContactsVC: UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return model.getAllThreads().count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "thread", for: indexPath)
		// Listing everybody
		cell.textLabel!.text = model.getAllThreads()[indexPath.row]
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let threadVC = storyboard.instantiateViewController(withIdentifier: "ThreadVC") as! ThreadVC
		threadVC.model = model
		threadVC.contact = model.getAllThreads()[indexPath.row]
		navigationController!.pushViewController(threadVC, animated: true)
	}
}

// MARK: ThreadVC -

class ThreadVC: UIViewController, UITableViewDataSource {
	var model: Model!
	var contact: String! // Model of the individual Thread Page
	
	@IBOutlet weak var tableView: UITableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.dataSource = self
		title = contact
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return model.getMessages(forContact: contact).count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "message") as! MessageCell
		let messages = model.getMessages(forContact: contact)
		cell.configureView(messages[indexPath.row])
		return cell
	}
}

class MessageCell: UITableViewCell {

	@IBOutlet weak var messageView: UIView!
	@IBOutlet weak var timeLabel: UILabel!
	@IBOutlet weak var messageLabel: UILabel!
	@IBOutlet weak var bubbleLeadingConstraint: NSLayoutConstraint!
	@IBOutlet weak var bubbleTrailingConstraint: NSLayoutConstraint!
	
	func configureView(_ message: Message) {
		messageLabel.text = message.text
		timeLabel.text = message.sent_at.formatted()
		messageView.layer.cornerRadius = 10
		messageView.layer.masksToBounds = true
		let fromMe = message.isFromMe()
		if fromMe {
			timeLabel.textAlignment = .right
			messageLabel.textColor = UIColor.white
			messageView.backgroundColor = #colorLiteral(red: 0, green: 0.6618174911, blue: 0.9620569348, alpha: 1)
			bubbleLeadingConstraint.constant = 60
			bubbleTrailingConstraint.constant = -12
		} else {
			timeLabel.textAlignment = .left
			messageLabel.textColor = UIColor.black
			messageView.backgroundColor = #colorLiteral(red: 0.8371008039, green: 0.8586425781, blue: 0.8633332849, alpha: 1)
			bubbleLeadingConstraint.constant = 12
			bubbleTrailingConstraint.constant = -60
		}
		// change alignment of bubble
	}
}
