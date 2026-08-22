//
//  ChatVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 20/08/26.
//

import UIKit

class ChatVC: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var MessagesendButton: UIButton!
    @IBOutlet weak var textfield: UITextField!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var backButton: UIButton!

    // MARK: - Local Messages

    private var senderMessages: [String] = []

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        setupTextField()
        setupSendButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        scrollToLatestMessage(animated: false)
    }

    // MARK: - Table View Setup

    private func setupTableView() {

        tableview.delegate = self
        tableview.dataSource = self

        tableview.separatorStyle = .none
        tableview.showsVerticalScrollIndicator = false
        tableview.keyboardDismissMode = .interactive

        // Dynamic row height
        tableview.rowHeight = UITableView.automaticDimension
        tableview.estimatedRowHeight = 80

        // Register sender message cell
        tableview.register(
            UINib(
                nibName: "ChatsenderUITableViewCell",
                bundle: nil
            ),
            forCellReuseIdentifier: "ChatsenderUITableViewCell"
        )

        // Register staff message cell for future API integration
        tableview.register(
            UINib(
                nibName: "ChatstaffUITableViewCell",
                bundle: nil
            ),
            forCellReuseIdentifier: "ChatstaffUITableViewCell"
        )
    }

    // MARK: - Text Field Setup

    private func setupTextField() {

        textfield.delegate = self
        textfield.placeholder = "Type a message..."
        textfield.returnKeyType = .send
        textfield.clearButtonMode = .whileEditing

        textfield.layer.cornerRadius =
            textfield.bounds.height / 2

        textfield.clipsToBounds = true

        textfield.addTarget(
            self,
            action: #selector(textFieldTextChanged),
            for: .editingChanged
        )

        updateSendButtonState()
    }

    // MARK: - Send Button Setup

    private func setupSendButton() {

        MessagesendButton.addTarget(
            self,
            action: #selector(sendButtonTapped),
            for: .touchUpInside
        )

        MessagesendButton.layer.cornerRadius =
            MessagesendButton.bounds.height / 2

        MessagesendButton.clipsToBounds = true
    }

    // MARK: - Send Message

    @objc
    private func sendButtonTapped() {

        let message =
            textfield.text?
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                ) ?? ""

        guard !message.isEmpty else {
            return
        }

        // Add the new local message.
        senderMessages.append(message)

        let newIndexPath = IndexPath(
            row: senderMessages.count - 1,
            section: 0
        )

        tableview.performBatchUpdates({

            tableview.insertRows(
                at: [newIndexPath],
                with: .automatic
            )

        }, completion: { [weak self] _ in

            self?.scrollToLatestMessage(
                animated: true
            )
        })

        // Clear the text field after sending.
        textfield.text = nil
        updateSendButtonState()
    }

    // MARK: - Text Field Change

    @objc
    private func textFieldTextChanged() {
        updateSendButtonState()
    }

    private func updateSendButtonState() {

        let text =
            textfield.text?
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                ) ?? ""

        let hasText = !text.isEmpty

        MessagesendButton.isEnabled = hasText
        MessagesendButton.alpha = hasText ? 1.0 : 0.5
    }

    // MARK: - Scroll to Latest Message

    private func scrollToLatestMessage(
        animated: Bool
    ) {

        guard !senderMessages.isEmpty else {
            return
        }

        let lastIndexPath = IndexPath(
            row: senderMessages.count - 1,
            section: 0
        )

        tableview.scrollToRow(
            at: lastIndexPath,
            at: .bottom,
            animated: animated
        )
    }

    // MARK: - Actions

    @IBAction func backButtonTapped(_ sender: UIButton) {

        if let navigationController = navigationController {

            navigationController.popViewController(
                animated: true
            )

        } else {

            dismiss(
                animated: true
            )
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension ChatVC:
    UITableViewDataSource,
    UITableViewDelegate {

    func numberOfSections(
        in tableView: UITableView
    ) -> Int {

        return 1
    }

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {

        return senderMessages.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        guard let cell =
                tableView.dequeueReusableCell(
                    withIdentifier:
                        "ChatsenderUITableViewCell",
                    for: indexPath
                ) as? ChatsenderUITableViewCell else {

            return UITableViewCell()
        }

        let message =
            senderMessages[indexPath.row]

        cell.selectionStyle = .none

        cell.configure(
            message: message,
            time: formattedCurrentTime()
        )

        return cell
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {

        return UITableView.automaticDimension
    }

    func tableView(
        _ tableView: UITableView,
        estimatedHeightForRowAt indexPath: IndexPath
    ) -> CGFloat {

        return 80
    }

    private func formattedCurrentTime() -> String {

        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"

        return formatter.string(
            from: Date()
        )
    }
}

// MARK: - UITextFieldDelegate

extension ChatVC: UITextFieldDelegate {

    func textFieldShouldReturn(
        _ textField: UITextField
    ) -> Bool {

        let message =
            textField.text?
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                ) ?? ""

        guard !message.isEmpty else {
            return false
        }

        sendButtonTapped()

        return true
    }
}
