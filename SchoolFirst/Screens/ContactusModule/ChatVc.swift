//
//  ChatVc.swift
//  SchoolFirst
//

import UIKit
import PhotosUI
import UniformTypeIdentifiers

// MARK: - Chat Message Model

struct ChatMessage: Codable {

    let text: String
    let isMe: Bool
    let timeString: String
    let senderName: String?
    var attachmentUrls: [String]?

    /// Local preview image (not encoded / not saved to UserDefaults)
    var localPreviewImageData: Data?

    var tickStatusRaw: String?

    var tickStatus: MessageTickStatus {
        get {
            switch tickStatusRaw {
            case "sent":
                return .sent
            case "read":
                return .read
            default:
                return .delivered
            }
        }
        set {
            switch newValue {
            case .sent:
                tickStatusRaw = "sent"
            case .delivered:
                tickStatusRaw = "delivered"
            case .read:
                tickStatusRaw = "read"
            }
        }
    }

    var hasAttachment: Bool {
        if let urls = attachmentUrls, !urls.isEmpty {
            return true
        }

        if localPreviewImageData != nil {
            return true
        }

        return false
    }

    enum CodingKeys: String, CodingKey {
        case text
        case isMe
        case timeString
        case senderName
        case attachmentUrls
        case tickStatusRaw
    }

    init(
        text: String,
        isMe: Bool,
        timeString: String,
        senderName: String?,
        tickStatus: MessageTickStatus = .delivered,
        attachmentUrls: [String]? = nil,
        localPreviewImageData: Data? = nil
    ) {
        self.text = text
        self.isMe = isMe
        self.timeString = timeString
        self.senderName = senderName
        self.attachmentUrls = attachmentUrls
        self.localPreviewImageData = localPreviewImageData

        switch tickStatus {
        case .sent:
            self.tickStatusRaw = "sent"

        case .delivered:
            self.tickStatusRaw = "delivered"

        case .read:
            self.tickStatusRaw = "read"
        }
    }
}

// MARK: - Chat Attachment Model

private struct ChatAttachment {

    let data: Data
    let fileName: String
    let mimeType: String
    let isImage: Bool
}

// MARK: - ChatVC

class ChatVC: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var AttachmentButton: UIButton!
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
    
    private var isUploading = false
    
    private let maxAttachments = 5
    
    private let maxFileSizeInBytes = 10 * 1024 * 1024
    
    // ============================================================
    // IMPORTANT:
    // DO NOT HARDCODE DEV URL HERE.
    //
    // DEV:
    // https://dev-api.schoolfirst.ai/
    //
    // PROD:
    // Uses the production base URL configured in PLISTVALUES.
    // ============================================================
    
    private var uploadAPIURL: String {
        
        let baseURL = PLISTVALUES.baseUrl
        
        if baseURL.hasSuffix("/") {
            return "\(baseURL)user/storage/upload"
        } else {
            return "\(baseURL)/user/storage/upload"
        }
    }
    
    private let attachmentFieldName = "files"
    
    // MARK: - Auth Headers For Normal JSON APIs
    
    private var authHeaders: [String: String] {
        
        var headers: [String: String] = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        if let token = getAccessToken() {
            
            let cleanedToken = token.trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            
            if cleanedToken.lowercased().hasPrefix("bearer ") ||
                cleanedToken.lowercased().hasPrefix("token ") {
                
                headers["Authorization"] = cleanedToken
                
            } else {
                
                headers["Authorization"] = "Bearer \(cleanedToken)"
            }
        }
        
        return headers
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupTableView()
        setupTextField()
        setupSendButton()
        setupAttachmentButton()
        
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
        
        // Debug logs for DEV / PROD verification
        print("====================================")
        print("🌍 CHAT CURRENT BASE URL")
        print(PLISTVALUES.baseUrl)
        print("📤 CHAT UPLOAD URL")
        print(uploadAPIURL)
        print("====================================")
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
                
                chatMessages =
                try JSONDecoder().decode(
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
    
    private func applyTicketData(_ data: TicketData) {
        
        titleLabel?.text =
        data.title ??
        ticketItem?.title ??
        "Chat"
        
        if let msgs = data.messages, !msgs.isEmpty {
            
            chatMessages = msgs.compactMap { msg -> ChatMessage? in
                
                let rawText =
                msg.message?
                    .trimmingCharacters(
                        in: .whitespacesAndNewlines
                    ) ?? ""
                
                // ==========================================
                // FIX: Extract attachment URLs from API response
                // Only use msg.attachments which exists in TicketMessage
                // ==========================================
                
                var urls: [String]? = nil
                
                // Only check for attachments property
                if let attachments = msg.attachments, !attachments.isEmpty {
                    urls = attachments
                }
                
                let hasText = !rawText.isEmpty
                
                let hasFiles =
                (urls?.isEmpty == false)
                
                guard hasText || hasFiles else {
                    return nil
                }
                
                let senderLower =
                msg.senderType?
                    .lowercased() ?? ""
                
                let isMe =
                senderLower == "user" ||
                senderLower == "student"
                
                let displayText: String
                
                if hasFiles,
                   isProbablyAttachmentPlaceholder(rawText) {
                    
                    displayText = ""
                    
                } else {
                    
                    displayText = rawText
                }
                
                return ChatMessage(
                    text: displayText,
                    isMe: isMe,
                    timeString: formatServerTime(
                        msg.createdAt ?? ""
                    ),
                    senderName:
                        isMe
                    ? nil
                    : "School Accounts Office",
                    tickStatus: .delivered,
                    attachmentUrls: urls
                )
            }
            
            saveToUserDefaults()
            
            tableview.reloadData()
            
            if !chatMessages.isEmpty {
                scrollToLatestMessage(animated: false)
            }
        }
    }
    
    private func isProbablyAttachmentPlaceholder(
        _ text: String
    ) -> Bool {
        
        let t = text.lowercased()
        
        if t.hasPrefix("📎") {
            return true
        }
        
        if t.contains("photo_") &&
            (
                t.hasSuffix(".jpg") ||
                t.hasSuffix(".jpeg") ||
                t.hasSuffix(".png")
            ) {
            
            return true
        }
        
        return false
    }
    
    // MARK: - Save Messages
    
    private func saveToUserDefaults() {
        
        guard let id = ticketId else {
            return
        }
        
        do {
            
            let data =
            try JSONEncoder().encode(chatMessages)
            
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
            
            return formatter.string(from: date)
        }
        
        iso.formatOptions =
        [.withInternetDateTime]
        
        if let date = iso.date(from: raw) {
            
            let formatter = DateFormatter()
            
            formatter.dateFormat =
            "dd MMM yyyy, hh:mm a"
            
            return formatter.string(from: date)
        }
        
        return raw
    }
    
    // MARK: - GET Ticket Detail
    
    private func fetchTicketDetails() {
        
        guard let ticketId = ticketId,
              !ticketId.isEmpty else {
            return
        }
        
        var base =
        API.GET_TICKET_DETAIL
        
        if !base.hasSuffix("/") {
            base += "/"
        }
        
        var url =
        base + ticketId
        
        if !url.hasSuffix("/") {
            url += "/"
        }
        
        NetworkManager.shared.request(
            urlString: url,
            method: .GET,
            headers: authHeaders
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
                        self.ticketItem?.title ?? "Chat"
                    }
                    
                case .failure:
                    
                    self.titleLabel?.text =
                    self.ticketItem?.title ?? "Chat"
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
        
        tableview.keyboardDismissMode =
            .interactive
        
        tableview.rowHeight =
        UITableView.automaticDimension
        
        tableview.estimatedRowHeight = 120
        
        tableview.register(
            ChatsenderUITableViewCell.self,
            forCellReuseIdentifier:
                ChatsenderUITableViewCell.reuseId
        )
        
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
        
        MessagesendButton.clipsToBounds =
        true
        
        updateSendButtonState()
    }
    
    // MARK: - Attachment Button Setup
    
    private func setupAttachmentButton() {
        
        AttachmentButton.addTarget(
            self,
            action: #selector(attachmentButtonTapped),
            for: .touchUpInside
        )
    }
    
    // MARK: - Attachment Button Tapped
    
    @objc
    private func attachmentButtonTapped() {
        
        view.endEditing(true)
        
        guard !isUploading else {
            
            showAlert(
                msg:
                    "Please wait, files are being uploaded..."
            )
            
            return
        }
        
        let alert =
        UIAlertController(
            title: "Add Attachment",
            message:
                "Choose an attachment source.",
            preferredStyle: .actionSheet
        )
        
        alert.addAction(
            UIAlertAction(
                title: "Photo Gallery",
                style: .default
            ) { [weak self] _ in
                
                self?.openPhotoGallery()
            }
        )
        
        alert.addAction(
            UIAlertAction(
                title: "Files",
                style: .default
            ) { [weak self] _ in
                
                self?.openFiles()
            }
        )
        
        alert.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel
            )
        )
        
        if let popover =
            alert.popoverPresentationController {
            
            popover.sourceView =
            AttachmentButton
            
            popover.sourceRect =
            AttachmentButton.bounds
        }
        
        present(
            alert,
            animated: true
        )
    }
    
    // MARK: - Photo Gallery
    
    private func openPhotoGallery() {
        
        if #available(iOS 14.0, *) {
            
            var configuration =
            PHPickerConfiguration()
            
            configuration.filter =
                .images
            
            configuration.selectionLimit =
            maxAttachments
            
            let picker =
            PHPickerViewController(
                configuration:
                    configuration
            )
            
            picker.delegate = self
            
            present(
                picker,
                animated: true
            )
            
        } else {
            
            let imagePicker =
            UIImagePickerController()
            
            imagePicker.sourceType =
                .photoLibrary
            
            imagePicker.delegate =
            self
            
            imagePicker.allowsEditing =
            false
            
            present(
                imagePicker,
                animated: true
            )
        }
    }
    
    // MARK: - Files Picker
    
    private func openFiles() {
        
        let documentPicker:
        UIDocumentPickerViewController
        
        if #available(iOS 14.0, *) {
            
            documentPicker =
            UIDocumentPickerViewController(
                forOpeningContentTypes:
                    [.item],
                asCopy: true
            )
            
        } else {
            
            documentPicker =
            UIDocumentPickerViewController(
                documentTypes:
                    ["public.data"],
                in: .import
            )
        }
        
        documentPicker.delegate =
        self
        
        documentPicker.allowsMultipleSelection =
        true
        
        present(
            documentPicker,
            animated: true
        )
    }
    
    // MARK: - Get Access Token
    
    private func getAccessToken() -> String? {
        
        let possibleKeys = [
            "ACCESSTOKEN",
            "accessToken",
            "access_token",
            "token"
        ]
        
        for key in possibleKeys {
            
            if let storedToken =
                UserDefaults.standard.string(
                    forKey: key
                ) {
                
                let cleaned =
                storedToken.trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
                
                if !cleaned.isEmpty {
                    
                    print(
                        "🟢 Access token found using key: \(key)"
                    )
                    
                    return cleaned
                }
            }
        }
        
        print(
            "❌ Access token was NOT found in UserDefaults."
        )
        
        return nil
    }
    
    // MARK: - Authorization Header
    
    private func applyAuthorizationHeader(
        to request: inout URLRequest
    ) {
        
        guard let token = getAccessToken() else {
            
            print(
                "❌ Authorization token was NOT found."
            )
            
            return
        }
        
        let cleanedToken =
        token.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        
        let authorizationValue: String
        
        if cleanedToken.lowercased()
            .hasPrefix("bearer ") {
            
            authorizationValue =
            cleanedToken
            
        } else if cleanedToken.lowercased()
            .hasPrefix("token ") {
            
            authorizationValue =
            cleanedToken
            
        } else {
            
            authorizationValue =
            "Bearer \(cleanedToken)"
        }
        
        request.setValue(
            authorizationValue,
            forHTTPHeaderField:
                "Authorization"
        )
        
        print(
            "🟢 Authorization header attached to upload request."
        )
    }
    
    // MARK: - Upload Files API
    
    private func uploadFilesToAPI(
        attachments: [ChatAttachment],
        completion:
        @escaping ([UploadedFile]?) -> Void
    ) {
        
        guard !attachments.isEmpty else {
            
            completion(nil)
            
            return
        }
        
        let currentUploadURL =
        uploadAPIURL
        
        guard let url =
                URL(string: currentUploadURL) else {
            
            showAlert(
                msg:
                    "Invalid upload API URL."
            )
            
            completion(nil)
            
            return
        }
        
        isUploading = true
        
        showLoader()
        
        let boundary =
        "Boundary-\(UUID().uuidString)"
        
        var request =
        URLRequest(url: url)
        
        request.httpMethod = "POST"
        
        request.timeoutInterval = 120
        
        request.setValue(
            "multipart/form-data; boundary=\(boundary)",
            forHTTPHeaderField:
                "Content-Type"
        )
        
        request.setValue(
            "application/json",
            forHTTPHeaderField:
                "Accept"
        )
        
        applyAuthorizationHeader(
            to: &request
        )
        
        var body =
        Data()
        
        for attachment in attachments {
            
            var safeFileName =
            attachment.fileName
                .replacingOccurrences(
                    of: "\"",
                    with: ""
                )
                .trimmingCharacters(
                    in:
                            .whitespacesAndNewlines
                )
            
            if safeFileName.isEmpty {
                
                safeFileName =
                "attachment-\(UUID().uuidString).dat"
            }
            
            body.append(
                "--\(boundary)\r\n"
                    .data(using: .utf8)!
            )
            
            body.append(
                "Content-Disposition: form-data; name=\"\(attachmentFieldName)\"; filename=\"\(safeFileName)\"\r\n"
                    .data(using: .utf8)!
            )
            
            body.append(
                "Content-Type: \(attachment.mimeType)\r\n\r\n"
                    .data(using: .utf8)!
            )
            
            body.append(
                attachment.data
            )
            
            body.append(
                "\r\n"
                    .data(using: .utf8)!
            )
        }
        
        body.append(
            "--\(boundary)--\r\n"
                .data(using: .utf8)!
        )
        
        request.httpBody =
        body
        
        print("====================================")
        print("📤 CHAT FILE UPLOAD API")
        print("🌍 Environment Base URL:")
        print(PLISTVALUES.baseUrl)
        print("📤 Upload URL:")
        print(url.absoluteString)
        print("📤 File Count:")
        print(attachments.count)
        print("📤 HTTP Method: POST")
        print("📤 Multipart Field:")
        print(attachmentFieldName)
        print("📤 Authorization: Attached")
        print("====================================")
        
        URLSession.shared.dataTask(
            with: request
        ) { [weak self]
            data,
            response,
            error in
            
            guard let self = self else {
                return
            }
            
            if let error = error {
                
                DispatchQueue.main.async {
                    
                    self.isUploading =
                    false
                    
                    self.hideLoader()
                    
                    self.showAlert(
                        msg:
                            "Upload failed: \(error.localizedDescription)"
                    )
                    
                    completion(nil)
                }
                
                return
            }
            
            guard let httpResponse =
                    response as? HTTPURLResponse else {
                
                DispatchQueue.main.async {
                    
                    self.isUploading =
                    false
                    
                    self.hideLoader()
                    
                    self.showAlert(
                        msg:
                            "Invalid response from server."
                    )
                    
                    completion(nil)
                }
                
                return
            }
            
            guard let data = data else {
                
                DispatchQueue.main.async {
                    
                    self.isUploading =
                    false
                    
                    self.hideLoader()
                    
                    self.showAlert(
                        msg:
                            "No data received from server."
                    )
                    
                    completion(nil)
                }
                
                return
            }
            
            let responseString =
            String(
                data: data,
                encoding: .utf8
            ) ?? ""
            
            print("====================================")
            print(
                "📥 CHAT UPLOAD RESPONSE: \(httpResponse.statusCode)"
            )
            print(responseString)
            print("====================================")
            
            if httpResponse.statusCode == 401 {
                
                DispatchQueue.main.async {
                    
                    self.isUploading =
                    false
                    
                    self.hideLoader()
                    
                    print(
                        "❌ CHAT UPLOAD API RETURNED 401"
                    )
                    
                    self.showAlert(
                        msg:
                            "Authorization failed. Please login again and try uploading the attachment."
                    )
                    
                    completion(nil)
                }
                
                return
            }
            
            guard (200...299).contains(
                httpResponse.statusCode
            ) else {
                
                DispatchQueue.main.async {
                    
                    self.isUploading =
                    false
                    
                    self.hideLoader()
                    
                    let message =
                    responseString.isEmpty
                    ? "Upload failed: Server error \(httpResponse.statusCode)"
                    : responseString
                    
                    self.showAlert(
                        msg: message
                    )
                    
                    completion(nil)
                }
                
                return
            }
            
            do {
                
                let uploadResponse =
                try JSONDecoder().decode(
                    UploadAPIResponse.self,
                    from: data
                )
                
                DispatchQueue.main.async {
                    
                    self.isUploading =
                    false
                    
                    self.hideLoader()
                    
                    if uploadResponse.success,
                       let files =
                        uploadResponse.data {
                        
                        print("====================================")
                        print("✅ CHAT FILE UPLOAD SUCCESS")
                        print(
                            "✅ Uploaded files: \(files.count)"
                        )
                        
                        for file in files {
                            
                            print(
                                "📄 \(file.original_filename)"
                            )
                            
                            print(
                                "🔗 \(file.file_url)"
                            )
                            
                            print(
                                "📁 \(file.file_path)"
                            )
                        }
                        
                        print("====================================")
                        
                        completion(
                            files.map {
                                $0.toUploadedFile()
                            }
                        )
                        
                    } else {
                        
                        self.showAlert(
                            msg:
                                uploadResponse.description
                        )
                        
                        completion(nil)
                    }
                }
                
            } catch {
                
                DispatchQueue.main.async {
                    
                    self.isUploading =
                    false
                    
                    self.hideLoader()
                    
                    print(
                        "❌ Upload response decoding failed:",
                        error.localizedDescription
                    )
                    
                    self.showAlert(
                        msg:
                            "Failed to parse upload response: \(error.localizedDescription)"
                    )
                    
                    completion(nil)
                }
            }
            
        }.resume()
    }
    
    // MARK: - Send Message Text
    
    @objc
    private func sendButtonTapped() {
        
        let message =
        textfield.text?
            .trimmingCharacters(
                in:
                        .whitespacesAndNewlines
            ) ?? ""
        
        guard !message.isEmpty else {
            return
        }
        
        guard let ticketId = ticketId,
              !ticketId.isEmpty else {
            
            showAlert(
                msg:
                    "Ticket ID is missing."
            )
            
            return
        }
        
        let item =
        ChatMessage(
            text: message,
            isMe: true,
            timeString:
                currentTimeString(),
            senderName: nil,
            tickStatus: .sent
        )
        
        chatMessages.append(item)
        
        let insertedIndex =
        chatMessages.count - 1
        
        let indexPath =
        IndexPath(
            row: insertedIndex,
            section: 0
        )
        
        textfield.text = ""
        
        updateSendButtonState()
        
        tableview.performBatchUpdates({
            
            tableview.insertRows(
                at: [indexPath],
                with: .automatic
            )
            
        }, completion: { [weak self] _ in
            
            self?.scrollToLatestMessage(
                animated: true
            )
        })
        
        postChatMessage(
            ticketId: ticketId,
            message: message,
            attachmentUrls: nil,
            insertedIndex: insertedIndex,
            indexPath: indexPath
        )
    }
    
    // MARK: - Send Attachment Message
    
    private func sendAttachmentMessage(
        uploadedFiles: [UploadedFile],
        localImageDataList: [Data]
    ) {
        
        guard let ticketId = ticketId,
              !ticketId.isEmpty else {
            
            showAlert(
                msg:
                    "Ticket ID is missing."
            )
            
            return
        }
        
        guard !uploadedFiles.isEmpty else {
            return
        }
        
        let fileURLs =
        uploadedFiles.map {
            $0.fileUrl
        }
        
        let previewData =
        localImageDataList.first
        
        let item =
        ChatMessage(
            text: "",
            isMe: true,
            timeString:
                currentTimeString(),
            senderName: nil,
            tickStatus: .sent,
            attachmentUrls:
                fileURLs,
            localPreviewImageData:
                previewData
        )
        
        chatMessages.append(item)
        
        let insertedIndex =
        chatMessages.count - 1
        
        let indexPath =
        IndexPath(
            row: insertedIndex,
            section: 0
        )
        
        tableview.performBatchUpdates({
            
            tableview.insertRows(
                at: [indexPath],
                with: .automatic
            )
            
        }, completion: { [weak self] _ in
            
            self?.scrollToLatestMessage(
                animated: true
            )
        })
        
        let apiMessage =
        uploadedFiles.count == 1
        ? "Photo"
        : "\(uploadedFiles.count) Photos"
        
        postChatMessage(
            ticketId: ticketId,
            message: apiMessage,
            attachmentUrls: fileURLs,
            insertedIndex: insertedIndex,
            indexPath: indexPath
        )
    }
    
    // MARK: - POST Chat Message
    
    private func postChatMessage(
        ticketId: String,
        message: String,
        attachmentUrls: [String]?,
        insertedIndex: Int,
        indexPath: IndexPath
    ) {
        
        var parameters:
        [String: Any] = [
            "ticket_id": ticketId,
            "message": message
        ]
        
        if let urls = attachmentUrls,
           !urls.isEmpty {
            
            parameters["attachments"] =
            urls
            
            parameters["files"] =
            urls
            
            parameters["file_urls"] =
            urls
        }
        
        NetworkManager.shared.request(
            urlString:
                API.SEND_TICKET_MESSAGE,
            method: .POST,
            parameters: parameters,
            headers: authHeaders
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
                        
                        if insertedIndex <
                            self.chatMessages.count {
                            
                            self.chatMessages[
                                insertedIndex
                            ].tickStatus =
                                .delivered
                            
                            self.saveToUserDefaults()
                            
                            self.tableview.reloadRows(
                                at: [indexPath],
                                with: .none
                            )
                        }
                        
                    } else {
                        
                        self.showAlert(
                            msg:
                                info.description.isEmpty
                            ? "Send failed."
                            : info.description
                        )
                    }
                    
                case .failure(let error):
                    
                    let errorMsg: String
                    
                    switch error {
                        
                    case .serverError(let msg):
                        
                        errorMsg = msg
                        
                    case .decodingError(let msg):
                        
                        errorMsg = msg
                        
                    case .noaccess:
                        
                        errorMsg =
                        "Session expired. Please re-login."
                        
                    default:
                        
                        errorMsg =
                        "Unable to send message. Please try again."
                    }
                    
                    self.showAlert(
                        msg: errorMsg
                    )
                }
            }
        }
    }
    
    // MARK: - Handle Selected Attachments
    
    private func handleSelectedAttachments(
        _ attachments: [ChatAttachment]
    ) {
        
        guard !attachments.isEmpty else {
            return
        }
        
        let allowed =
        Array(
            attachments.prefix(
                maxAttachments
            )
        )
        
        let localImageDataList =
        allowed.compactMap {
            att -> Data? in
            
            att.isImage
            ? att.data
            : nil
        }
        
        uploadFilesToAPI(
            attachments: allowed
        ) { [weak self] uploadedFiles in
            
            guard let self = self else {
                return
            }
            
            if let files = uploadedFiles,
               !files.isEmpty {
                
                self.sendAttachmentMessage(
                    uploadedFiles: files,
                    localImageDataList:
                        localImageDataList
                )
            }
        }
        
        if attachments.count >
            allowed.count {
            
            showAlert(
                msg:
                    "Only \(maxAttachments) attachments can be selected at once."
            )
        }
    }
    
    // MARK: - MIME Type
    
    private func mimeType(
        for fileExtension: String
    ) -> String {
        
        switch fileExtension.lowercased() {
            
        case "jpg", "jpeg":
            return "image/jpeg"
            
        case "png":
            return "image/png"
            
        case "gif":
            return "image/gif"
            
        case "heic", "heif":
            return "image/heic"
            
        case "pdf":
            return "application/pdf"
            
        case "doc":
            return "application/msword"
            
        case "docx":
            return
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
            
        case "xls":
            return "application/vnd.ms-excel"
            
        case "xlsx":
            return
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
            
        case "txt":
            return "text/plain"
            
        case "mp4":
            return "video/mp4"
            
        case "mov":
            return "video/quicktime"
            
        default:
            return "application/octet-stream"
        }
    }
    
    private func isImageExtension(
        _ ext: String
    ) -> Bool {
        
        [
            "jpg",
            "jpeg",
            "png",
            "gif",
            "heic",
            "heif",
            "webp",
            "bmp"
        ]
            .contains(
                ext.lowercased()
            )
    }
    
    // MARK: - Current Time
    
    // MARK: - Current Time
    
    private func currentTimeString() -> String {
        
        // Return full ISO8601 date so the chat cell can
        // correctly detect it as "today" and show only the time.
        // (Previously "hh:mm a" caused year to default to 2000)
        let formatter = ISO8601DateFormatter()
        
        formatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]
        
        return formatter.string(from: Date())
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
                in:
                        .whitespacesAndNewlines
            ) ?? ""
        
        let hasText =
        !text.isEmpty
        
        MessagesendButton.isEnabled =
        hasText
        
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
        
        let indexPath =
        IndexPath(
            row:
                chatMessages.count - 1,
            section: 0
        )
        
        tableview.scrollToRow(
            at: indexPath,
            at: .bottom,
            animated: animated
        )
    }
    
    // MARK: - Back Button
    
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let queriesHistoryVC = storyboard.instantiateViewController(
            withIdentifier: "QuerieshistoryVC"
        ) as? QuerieshistoryVC {
            
            navigationController?.pushViewController(
                queriesHistoryVC,
                animated: true
            )
        }
    }
}

// MARK: - UITableViewDataSource & Delegate

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

        let msg =
            chatMessages[indexPath.row]

        if msg.isMe {

            guard let cell =
                tableView.dequeueReusableCell(
                    withIdentifier:
                        ChatUserTableViewCell.reuseId,
                    for: indexPath
                ) as?
                ChatUserTableViewCell else {

                return UITableViewCell()
            }

            cell.configure(
                text: msg.text,
                time: msg.timeString,
                tickStatus:
                    msg.tickStatus,
                attachmentUrls:
                    msg.attachmentUrls,
                localImageData:
                    msg.localPreviewImageData
            )

            return cell

        } else {

            guard let cell =
                tableView.dequeueReusableCell(
                    withIdentifier:
                        ChatsenderUITableViewCell.reuseId,
                    for: indexPath
                ) as?
                ChatsenderUITableViewCell else {

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

        let msg =
            chatMessages[indexPath.row]

        return msg.hasAttachment
            ? 220
            : 100
    }
}

// MARK: - UITextFieldDelegate

extension ChatVC:
    UITextFieldDelegate {

    func textFieldShouldReturn(
        _ textField: UITextField
    ) -> Bool {

        let message =
            textField.text?
                .trimmingCharacters(
                    in:
                        .whitespacesAndNewlines
                ) ?? ""

        guard !message.isEmpty else {
            return false
        }

        sendButtonTapped()

        return true
    }
}

// MARK: - PHPickerViewControllerDelegate

@available(iOS 14.0, *)
extension ChatVC:
    PHPickerViewControllerDelegate {

    func picker(
        _ picker: PHPickerViewController,
        didFinishPicking results:
            [PHPickerResult]
    ) {

        picker.dismiss(
            animated: true
        )

        guard !results.isEmpty else {
            return
        }

        let group =
            DispatchGroup()

        let lock =
            NSLock()

        var attachments:
            [ChatAttachment] = []

        var skippedLargeImage =
            false

        for (index, result)
            in results.enumerated() {

            group.enter()

            result.itemProvider.loadObject(
                ofClass: UIImage.self
            ) { [weak self]
                object,
                _ in

                defer {
                    group.leave()
                }

                guard let self = self,
                      let image =
                        object as? UIImage,
                      let imageData =
                        image.jpegData(
                            compressionQuality:
                                0.75
                        ) else {

                    return
                }

                guard imageData.count <=
                        self.maxFileSizeInBytes
                else {

                    lock.lock()

                    skippedLargeImage =
                        true

                    lock.unlock()

                    return
                }

                let attachment =
                    ChatAttachment(
                        data:
                            imageData,
                        fileName:
                            "Photo_\(index + 1)_\(Int(Date().timeIntervalSince1970)).jpg",
                        mimeType:
                            "image/jpeg",
                        isImage:
                            true
                    )

                lock.lock()

                attachments.append(
                    attachment
                )

                lock.unlock()
            }
        }

        group.notify(
            queue: .main
        ) { [weak self] in

            guard let self = self else {
                return
            }

            if !attachments.isEmpty {

                self.handleSelectedAttachments(
                    attachments
                )
            }

            if skippedLargeImage {

                self.showAlert(
                    msg:
                        "One or more images were skipped because file size exceeds 10 MB."
                )
            }
        }
    }
}

// MARK: - UIImagePickerControllerDelegate

extension ChatVC:
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate {

    func imagePickerController(
        _ picker:
            UIImagePickerController,
        didFinishPickingMediaWithInfo info:
            [
                UIImagePickerController.InfoKey:
                    Any
            ]
    ) {

        picker.dismiss(
            animated: true
        )

        guard let image =
                info[.originalImage]
                    as? UIImage,
              let imageData =
                image.jpegData(
                    compressionQuality:
                        0.75
                ) else {

            return
        }

        guard imageData.count <=
                maxFileSizeInBytes else {

            showAlert(
                msg:
                    "Selected image exceeds maximum file size of 10 MB."
            )

            return
        }

        let attachment =
            ChatAttachment(
                data:
                    imageData,
                fileName:
                    "Photo_\(UUID().uuidString).jpg",
                mimeType:
                    "image/jpeg",
                isImage:
                    true
            )

        handleSelectedAttachments(
            [attachment]
        )
    }

    func imagePickerControllerDidCancel(
        _ picker:
            UIImagePickerController
    ) {

        picker.dismiss(
            animated: true
        )
    }
}

// MARK: - UIDocumentPickerDelegate

extension ChatVC:
    UIDocumentPickerDelegate {

    func documentPicker(
        _ controller:
            UIDocumentPickerViewController,
        didPickDocumentsAt urls:
            [URL]
    ) {

        guard !urls.isEmpty else {
            return
        }

        let selectedURLs =
            Array(
                urls.prefix(
                    maxAttachments
                )
            )

        DispatchQueue.global(
            qos: .userInitiated
        ).async { [weak self] in

            guard let self = self else {
                return
            }

            var attachments:
                [ChatAttachment] = []

            var skippedFileCount =
                0

            for url in selectedURLs {

                let canAccess =
                    url.startAccessingSecurityScopedResource()

                defer {

                    if canAccess {

                        url.stopAccessingSecurityScopedResource()
                    }
                }

                do {

                    let data =
                        try Data(
                            contentsOf:
                                url,
                            options:
                                [.mappedIfSafe]
                        )

                    if data.count >
                        self.maxFileSizeInBytes {

                        skippedFileCount += 1

                        continue
                    }

                    var fileName =
                        url.lastPathComponent
                            .trimmingCharacters(
                                in:
                                    .whitespacesAndNewlines
                            )

                    if fileName.isEmpty {

                        fileName =
                            "File_\(UUID().uuidString).dat"
                    }

                    let ext =
                        url.pathExtension

                    let attachment =
                        ChatAttachment(
                            data:
                                data,
                            fileName:
                                fileName,
                            mimeType:
                                self.mimeType(
                                    for: ext
                                ),
                            isImage:
                                self.isImageExtension(
                                    ext
                                )
                        )

                    attachments.append(
                        attachment
                    )

                } catch {

                    print(
                        "Unable to read selected file:",
                        error.localizedDescription
                    )

                    skippedFileCount += 1
                }
            }

            DispatchQueue.main.async { [weak self] in

                guard let self = self else {
                    return
                }

                if !attachments.isEmpty {

                    self.handleSelectedAttachments(
                        attachments
                    )
                }

                if skippedFileCount > 0 {

                    self.showAlert(
                        msg:
                            "\(skippedFileCount) file(s) could not be attached. Maximum allowed file size is 10 MB."
                    )
                }

                if urls.count >
                    selectedURLs.count {

                    self.showAlert(
                        msg:
                            "Only \(self.maxAttachments) attachments can be selected."
                    )
                }
            }
        }
    }

    func documentPickerWasCancelled(
        _ controller:
            UIDocumentPickerViewController
    ) {

        print(
            "Document picker cancelled."
        )
    }
}
