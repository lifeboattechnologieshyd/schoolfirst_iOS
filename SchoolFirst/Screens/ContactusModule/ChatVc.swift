//
//  ChatVc.swift
//  SchoolFirst
//

import UIKit

// MARK: - Chat Message

struct ChatMessage: Codable {

    let text: String
    let isMe: Bool
    let timeString: String
    let senderName: String?
}

// MARK: - ChatVC

class ChatVC: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var MessagesendButton: UIButton!
    @IBOutlet weak var textfield: UITextField!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var backButton: UIButton!

    // MARK: - Properties

    var ticketId: String?
    var ticketItem: TicketItem?
    var ticketDetail: TicketData?

    private var chatMessages: [ChatMessage] = []

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        setupTextField()
        setupSendButton()

        titleLabel?.text =
            ticketItem?.title ??
            ticketDetail?.title ??
            "Chat"

        loadInitialData()

        tableview.reloadData()

        if !chatMessages.isEmpty {
            scrollToLatestMessage(animated: false)
        }

        if let id = ticketId, !id.isEmpty {
            fetchTicketDetails()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        scrollToLatestMessage(animated: false)
    }

    // MARK: - Load Initial Data

    private func loadInitialData() {

        if let detail = ticketDetail {

            applyTicketData(detail)

            return
        }

        if let id = ticketId,
           let data = UserDefaults.standard.data(
                forKey: "chat_msgs_\(id)"
           ) {

            do {

                chatMessages = try JSONDecoder().decode(
                    [ChatMessage].self,
                    from: data
                )

                titleLabel?.text =
                    ticketItem?.title ?? "Chat"

                tableview.reloadData()

                if !chatMessages.isEmpty {
                    scrollToLatestMessage(animated: false)
                }

            } catch {

                chatMessages = []
            }
        }
    }

    // MARK: - Apply Ticket Data

    private func applyTicketData(
        _ data: TicketData
    ) {

        titleLabel?.text =
            data.title ??
            ticketItem?.title ??
            "Chat"

        if let msgs = data.messages,
           !msgs.isEmpty {

            chatMessages = msgs.compactMap {
                msg -> ChatMessage? in

                guard let txt = msg.message?
                    .trimmingCharacters(
                        in: .whitespacesAndNewlines
                    ),
                    !txt.isEmpty
                else {
                    return nil
                }

                let senderLower =
                    msg.senderType?
                        .lowercased() ?? ""

                // ==========================================
                // USER
                // true = RIGHT SIDE
                // ==========================================

                let isMe =
                    senderLower == "user" ||
                    senderLower == "student"

                return ChatMessage(
                    text: txt,
                    isMe: isMe,
                    timeString: formatServerTime(
                        msg.createdAt ?? ""
                    ),
                    senderName: isMe
                        ? nil
                        : "School Accounts Office"
                )
            }

            saveToUserDefaults()

            tableview.reloadData()

            if !chatMessages.isEmpty {
                scrollToLatestMessage(animated: false)
            }
        }
    }

    // MARK: - Save Messages

    private func saveToUserDefaults() {

        guard let id = ticketId else {
            return
        }

        do {

            let data = try JSONEncoder().encode(
                chatMessages
            )

            UserDefaults.standard.set(
                data,
                forKey: "chat_msgs_\(id)"
            )

        } catch {

            print(
                "Failed to save chat messages: \(error)"
            )
        }
    }

    // MARK: - Format Server Time

    private func formatServerTime(
        _ raw: String
    ) -> String {

        if raw.isEmpty {
            return ""
        }

        let iso = ISO8601DateFormatter()

        iso.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]

        if let date = iso.date(from: raw) {

            let formatter = DateFormatter()

            formatter.dateFormat =
                "dd MMM yyyy, hh:mm a"

            return formatter.string(
                from: date
            )
        }

        iso.formatOptions = [
            .withInternetDateTime
        ]

        if let date = iso.date(from: raw) {

            let formatter = DateFormatter()

            formatter.dateFormat =
                "dd MMM yyyy, hh:mm a"

            return formatter.string(
                from: date
            )
        }

        return raw
    }

    // MARK: - GET Ticket Detail

    private func fetchTicketDetails() {

        guard let ticketId = ticketId,
              !ticketId.isEmpty
        else {
            return
        }

        var base = API.GET_TICKET_DETAIL

        if !base.hasSuffix("/") {
            base += "/"
        }

        let url = base + ticketId

        NetworkManager.shared.request(
            urlString: url,
            method: .GET
        ) { [weak self] (
            result: Result<
                APIResponse<TicketData>,
                NetworkError
            >
        ) in

            guard let self = self else {
                return
            }

            DispatchQueue.main.async {

                switch result {

                case .success(let info):

                    if info.success,
                       let data = info.data {

                        self.applyTicketData(data)

                    } else {

                        self.titleLabel?.text =
                            self.ticketItem?.title ??
                            "Chat"
                    }

                case .failure:

                    self.titleLabel?.text =
                        self.ticketItem?.title ??
                        "Chat"
                }
            }
        }
    }

    // MARK: - TableView Setup

    private func setupTableView() {

        tableview.delegate = self
        tableview.dataSource = self

        tableview.separatorStyle = .none

        tableview.showsVerticalScrollIndicator = false

        tableview.keyboardDismissMode = .interactive

        tableview.rowHeight =
            UITableView.automaticDimension

        tableview.estimatedRowHeight = 100

        // ==========================================
        // SENDER CELL
        // LEFT + LIGHT GRAY
        // ==========================================

        tableview.register(
            ChatsenderUITableViewCell.self,
            forCellReuseIdentifier:
                ChatsenderUITableViewCell.reuseId
        )

        // ==========================================
        // USER CELL
        // RIGHT + BLUE
        // ==========================================

        tableview.register(
            ChatUserTableViewCell.self,
            forCellReuseIdentifier:
                ChatUserTableViewCell.reuseId
        )
    }

    // MARK: - TextField Setup

    private func setupTextField() {

        textfield.delegate = self

        textfield.placeholder =
            "Type a message..."

        textfield.returnKeyType = .send

        textfield.clearButtonMode =
            .whileEditing

        textfield.font =
            UIFont.systemFont(ofSize: 15)

        textfield.textColor = .black

        textfield.backgroundColor =
            .systemBackground

        textfield.layer.cornerRadius = 12

        textfield.layer.borderWidth = 0.5

        textfield.layer.borderColor =
            UIColor.systemGray4.cgColor

        textfield.addTarget(
            self,
            action: #selector(textFieldDidChange),
            for: .editingChanged
        )
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

        updateSendButtonState()
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

        guard let ticketId = ticketId,
              !ticketId.isEmpty
        else {

            showAlert(
                msg: "Ticket ID is missing."
            )

            return
        }

        let parameters: [String: Any] = [

            "ticket_id": ticketId,

            "message": message
        ]

        NetworkManager.shared.request(
            urlString: API.SEND_TICKET_MESSAGE,
            method: .POST,
            parameters: parameters
        ) { [weak self] (
            result: Result<
                APIResponse<SendTicketMessageData>,
                NetworkError
            >
        ) in

            guard let self = self else {
                return
            }

            DispatchQueue.main.async {

                switch result {

                case .success(let info):

                    if info.success {

                        // ==================================
                        // USER MESSAGE
                        // isMe = TRUE
                        // RIGHT SIDE
                        // BLUE BUBBLE
                        // ==================================

                        let item = ChatMessage(
                            text: message,
                            isMe: true,
                            timeString:
                                self.currentTimeString(),
                            senderName: nil
                        )

                        self.chatMessages.append(item)

                        self.saveToUserDefaults()

                        let indexPath = IndexPath(
                            row:
                                self.chatMessages.count - 1,
                            section: 0
                        )

                        self.tableview.performBatchUpdates({

                            self.tableview.insertRows(
                                at: [indexPath],
                                with: .automatic
                            )

                        }, completion: { _ in

                            self.scrollToLatestMessage(
                                animated: true
                            )
                        })

                        self.textfield.text = ""

                        self.updateSendButtonState()

                    } else {

                        self.showAlert(
                            msg:
                                info.description.isEmpty
                                ? "Send failed."
                                : info.description
                        )
                    }

                case .failure(let error):

                    self.showAlert(
                        msg:
                            error.localizedDescription
                    )
                }
            }
        }
    }

    // MARK: - Current Time

    private func currentTimeString() -> String {

        let formatter = DateFormatter()

        formatter.dateFormat = "hh:mm a"

        return formatter.string(
            from: Date()
        )
    }

    // MARK: - TextField Change

    @objc
    private func textFieldDidChange() {

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

        MessagesendButton.alpha =
            hasText ? 1.0 : 0.5
    }

    // MARK: - Scroll

    private func scrollToLatestMessage(
        animated: Bool
    ) {

        guard !chatMessages.isEmpty else {
            return
        }

        let indexPath = IndexPath(
            row: chatMessages.count - 1,
            section: 0
        )

        tableview.scrollToRow(
            at: indexPath,
            at: .bottom,
            animated: animated
        )
    }

    // MARK: - Back Button

    @IBAction
    func backButtonTapped(
        _ sender: UIButton
    ) {

        if let navigationController =
            navigationController {

            navigationController.popViewController(
                animated: true
            )

        } else {

            dismiss(animated: true)
        }
    }
}

// MARK: - UITableViewDataSource

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

        return chatMessages.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let msg = chatMessages[indexPath.row]

        // ==================================================
        // USER
        // isMe = TRUE
        // RIGHT SIDE
        // BLUE BUBBLE
        // ==================================================

        if msg.isMe {

            guard let cell =
                tableView.dequeueReusableCell(
                    withIdentifier:
                        ChatUserTableViewCell.reuseId,
                    for: indexPath
                ) as? ChatUserTableViewCell
            else {

                return UITableViewCell()
            }

            cell.configure(
                text: msg.text,
                time: msg.timeString
            )

            return cell
        }

        // ==================================================
        // SENDER / SUPPORT
        // isMe = FALSE
        // LEFT SIDE
        // LIGHT GRAY BUBBLE
        // ==================================================

        else {

            guard let cell =
                tableView.dequeueReusableCell(
                    withIdentifier:
                        ChatsenderUITableViewCell.reuseId,
                    for: indexPath
                ) as? ChatsenderUITableViewCell
            else {

                return UITableViewCell()
            }

            cell.configure(
                message: msg.text,
                time: msg.timeString
            )

            return cell
        }
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

        return 100
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
