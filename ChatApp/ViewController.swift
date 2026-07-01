//
//  ViewController.swift
//  ChatApp
//
//  Created by mlcmc on 7/1/25.
//

import UIKit

// MARK: ContactsVC -

class ContactsVC: UIViewController, ModelDelegate {
    @IBOutlet var tableView: UITableView!
    var model: Model!

    override func viewDidLoad() {
        super.viewDidLoad()
        model = Model()
        model.delegate = self
        tableView.delegate = self
        tableView.dataSource = self

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
    }

    @IBAction func addContactPressed(_: Any) {
        let alert = UIAlertController(
            title: "Add New Contact",
            message: nil,
            preferredStyle: .alert
        )
        alert.addTextField()
        alert.addAction(.init(title: "Save", style: .default, handler: { _ in
            let contactName = alert.textFields![0].text ?? ""
            if !contactName.isEmpty {
                self.model.addContact(newContact: contactName)
            }
        }))
        alert.addAction(.init(title: "Cancel", style: .destructive))
        present(alert, animated: true)
    }

    func onContactsChanged() {
        tableView.reloadData()
    }
}

extension ContactsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return model.getAllThreads().count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "thread",
            for: indexPath
        )
        // Listing everybody
        cell.textLabel!.text = model.getAllThreads()[indexPath.row]
        return cell
    }

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let threadVC = storyboard
            .instantiateViewController(withIdentifier: "ThreadVC") as! ThreadVC
        threadVC.model = model
        threadVC.contact = model.getAllThreads()[indexPath.row]
        navigationController!.pushViewController(threadVC, animated: true)
    }
}

// MARK: ThreadVC -

class ThreadVC: UIViewController, UITableViewDataSource {
    private let minimumInputHeight: CGFloat = 44 // RMV - 1 line
    private let maximumInputHeight: CGFloat = 120 // RMV - 6 lines
    private let messageFont = UIFont.systemFont(ofSize: 17)
    private let timestampFont = UIFont.systemFont(ofSize: 14)

    var model: Model!
    var contact: String! // Model of the individual Thread Page

    @IBOutlet var tableView: UITableView!
    @IBOutlet var messageTextView: UITextView! // RMV
    @IBOutlet var sendButton: UIButton! // RMV
    @IBOutlet var inputBarHeightConstraint: NSLayoutConstraint! // RMV

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        title = contact

        // RMV
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.isScrollEnabled = true
        tableView.alwaysBounceVertical = true

        // RMV
        messageTextView.delegate = self
        messageTextView.layer.borderColor = UIColor.separator.cgColor
        messageTextView.layer.borderWidth = 1
        messageTextView.layer.cornerRadius = 6
        messageTextView.textContainerInset = UIEdgeInsets(
            top: 8,
            left: 8,
            bottom: 8,
            right: 8
        )

        // RMV
        sendButton.isEnabled = false
        sendButton.setImage(
            UIImage(systemName: "paperplane.fill"),
            for: .normal
        )
    }

    // RMV - Scrolls the TableView to the bottom
    //       when this screen is initially displayed.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollToBottom(animated: false)
    }

    // RMV - Scrolls TableView so last message is visible.
    private func scrollToBottom(animated: Bool) {
        let messageCount = model.getMessages(forContact: contact).count
        guard messageCount > 0 else { return }

        tableView.layoutIfNeeded()
        let indexPath = IndexPath(row: messageCount - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
    }

    // RMV - Updates the message input height so it fits the entered text,
    //      but not more than 6 lines.
    private func updateInputHeight() {
        let fittingSize = CGSize(
            width: messageTextView.bounds.width,
            height: .greatestFiniteMagnitude
        )
        let height = messageTextView.sizeThatFits(fittingSize).height
        inputBarHeightConstraint.constant = min(
            max(height, minimumInputHeight),
            maximumInputHeight
        )
        messageTextView.isScrollEnabled = height > maximumInputHeight
        view.layoutIfNeeded()
    }

    // RMV
    @IBAction func sendButtonPressed(_: Any) {
        guard let text = messageTextView.text, !text.isEmpty else { return }

        // Send the message.
        model.addMessage(Message(
            from: ME,
            to: contact,
            text: text,
            sent_at: Date()
        ))

        // Reset the message input and send button.
        messageTextView.text = ""
        sendButton.isEnabled = false
        updateInputHeight() // resets to 1 line

        // The table of messages doesn't update without this.
        tableView.reloadData()
        scrollToBottom(animated: true)
    }

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return model.getMessages(forContact: contact).count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView
            .dequeueReusableCell(withIdentifier: "message") as! MessageCell
        let messages = model.getMessages(forContact: contact)
        cell.configureView(messages[indexPath.row])
        return cell
    }
}

// RMV - Calculates each message row height from its text so
// existing messages keep their height when new messages are added.
extension ThreadVC: UITableViewDelegate {
    // Computes the required height for a given table row
    // that contains a message bubble.
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        let message = model.getMessages(forContact: contact)[indexPath.row]
        let horizontalMargins: CGFloat = 72
        let bubbleHorizontalPadding: CGFloat = 24
        let labelWidth = tableView.bounds
            .width - horizontalMargins - bubbleHorizontalPadding
        let labelSize = CGSize(
            width: labelWidth,
            height: .greatestFiniteMagnitude
        )
        let textHeight = (message.text as NSString)
            .boundingRect(
                with: labelSize,
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: [.font: messageFont],
                context: nil
            )
            .height

        let bubbleVerticalPadding: CGFloat = 16
        let cellBottomPadding: CGFloat = 12
        return ceil(
            textHeight +
                bubbleVerticalPadding +
                timestampFont.lineHeight +
                cellBottomPadding
        )
    }
}

// RMV
extension ThreadVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updateInputHeight()

        // The send button is only enabled when text has been entered.
        sendButton.isEnabled = !textView.text.isEmpty
    }
}

class MessageCell: UITableViewCell {
    @IBOutlet var messageView: UIView!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var bubbleLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var bubbleTrailingConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        messageLabel.numberOfLines = 0
        messageLabel.lineBreakMode = .byWordWrapping
    }

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
