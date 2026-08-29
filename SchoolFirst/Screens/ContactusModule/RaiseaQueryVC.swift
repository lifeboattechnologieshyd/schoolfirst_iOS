//
//  RaiseaQueryVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 20/08/26.
//

import UIKit
import PhotosUI
import UniformTypeIdentifiers

// MARK: - Uploaded File Model

struct UploadedFile {
    let originalFilename: String
    let fileUrl: String
    let filePath: String
}

// MARK: - Upload API Response Model

struct UploadAPIResponse: Codable {
    let success: Bool
    let errorCode: Int
    let description: String
    let total: Int
    let data: [UploadedFileData]?
}

struct UploadedFileData: Codable {
    let original_filename: String
    let file_url: String
    let file_path: String

    func toUploadedFile() -> UploadedFile {
        return UploadedFile(
            originalFilename: original_filename,
            fileUrl: file_url,
            filePath: file_path
        )
    }
}

// MARK: - Attachment Model

private struct TicketAttachment {
    let data: Data
    let fileName: String
    let mimeType: String
}

// MARK: - Raise Query VC

class RaiseaQueryVC: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet weak var containerview: UIView!
    @IBOutlet weak var AttachmentButton: UIButton!
    @IBOutlet weak var Descriptiontextfield: UITextField!
    @IBOutlet weak var titletextfield: UITextField!
    @IBOutlet weak var Attechmentsbackgoundview: UIView!
    @IBOutlet weak var SumitqueryButton: UIButton!
    @IBOutlet weak var backButton: UIButton!

    // MARK: - Properties

    private var selectedAttachments: [TicketAttachment] = []
    private var uploadedFiles: [UploadedFile] = []

    private var isUploading = false

    private let maxAttachments = 5
    private let maxFileSizeInBytes = 10 * 1024 * 1024

    // ============================================================
    // IMPORTANT:
    // DO NOT HARDCODE DEV URL HERE.
    //
    // This automatically uses:
    // DEV  -> https://dev-api.schoolfirst.ai/
    // PROD -> your production base URL
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

    // MARK: - Attachment Preview Label

    private let attachmentPreviewLabel: UILabel = {

        let label = UILabel()

        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .darkGray
        label.lineBreakMode = .byTruncatingTail

        return label
    }()

    // MARK: - Upload Status Label

    private let uploadStatusLabel: UILabel = {

        let label = UILabel()

        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .systemBlue
        label.textAlignment = .center
        label.isHidden = true

        return label
    }()

    // MARK: - Description TextView

    private let descriptionTextView: UITextView = {

        let textView = UITextView()

        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.textColor = .black
        textView.backgroundColor = .clear
        textView.isScrollEnabled = true

        textView.textContainer.lineBreakMode = .byWordWrapping

        textView.textContainerInset = UIEdgeInsets(
            top: 10,
            left: 8,
            bottom: 10,
            right: 8
        )

        textView.autocorrectionType = .default
        textView.returnKeyType = .default

        return textView
    }()

    // MARK: - Description Placeholder

    private let descriptionPlaceholderLabel: UILabel = {

        let label = UILabel()

        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Describe your query in detail..."
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = UIColor.lightGray
        label.numberOfLines = 0

        return label
    }()

    private var descriptionText: String {

        return descriptionTextView.text
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
    }

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupDescriptionTextView()
        setupAttachmentContainer()
        setupAttachmentBackgroundTap()

        updateAttachmentUI()
        updateDescriptionPlaceholderVisibility()

        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )

        tap.cancelsTouchesInView = false

        view.addGestureRecognizer(tap)

        // Debug only - useful for DEV/PROD checking
        print("====================================")
        print("🌍 Current Base URL:")
        print(PLISTVALUES.baseUrl)
        print("📤 Upload URL:")
        print(uploadAPIURL)
        print("====================================")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        setupAttachmentBorder()
    }

    // MARK: - Attachment Border

    private func setupAttachmentBorder() {
        // Dotted border intentionally removed.
    }

    // MARK: - Attachment Background Tap

    private func setupAttachmentBackgroundTap() {

        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(attachmentBackgroundTapped)
        )

        Attechmentsbackgoundview.addGestureRecognizer(
            tapGesture
        )

        Attechmentsbackgoundview.isUserInteractionEnabled = true
    }

    @objc private func attachmentBackgroundTapped() {
        AttachmentButtonTapped(AttachmentButton)
    }

    // MARK: - Description TextView Setup

    private func setupDescriptionTextView() {

        guard let parentView = Descriptiontextfield.superview else {
            print("⚠️ Descriptiontextfield has no superview.")
            return
        }

        descriptionTextView.backgroundColor =
            Descriptiontextfield.backgroundColor

        descriptionTextView.layer.cornerRadius =
            Descriptiontextfield.layer.cornerRadius

        descriptionTextView.layer.borderWidth =
            Descriptiontextfield.layer.borderWidth

        descriptionTextView.layer.borderColor =
            Descriptiontextfield.layer.borderColor

        descriptionTextView.clipsToBounds = true

        if let existingFont = Descriptiontextfield.font {

            descriptionTextView.font = existingFont
            descriptionPlaceholderLabel.font = existingFont
        }

        if let existingPlaceholder =
            Descriptiontextfield.placeholder,
           !existingPlaceholder.isEmpty {

            descriptionPlaceholderLabel.text =
                existingPlaceholder
        }

        Descriptiontextfield.isHidden = true
        Descriptiontextfield.isUserInteractionEnabled = false

        parentView.addSubview(descriptionTextView)

        NSLayoutConstraint.activate([

            descriptionTextView.leadingAnchor.constraint(
                equalTo: Descriptiontextfield.leadingAnchor
            ),

            descriptionTextView.trailingAnchor.constraint(
                equalTo: Descriptiontextfield.trailingAnchor
            ),

            descriptionTextView.topAnchor.constraint(
                equalTo: Descriptiontextfield.topAnchor
            ),

            descriptionTextView.bottomAnchor.constraint(
                equalTo: Descriptiontextfield.bottomAnchor
            )
        ])

        descriptionTextView.addSubview(
            descriptionPlaceholderLabel
        )

        NSLayoutConstraint.activate([

            descriptionPlaceholderLabel.leadingAnchor.constraint(
                equalTo: descriptionTextView.leadingAnchor,
                constant: 12
            ),

            descriptionPlaceholderLabel.trailingAnchor.constraint(
                equalTo: descriptionTextView.trailingAnchor,
                constant: -12
            ),

            descriptionPlaceholderLabel.topAnchor.constraint(
                equalTo: descriptionTextView.topAnchor,
                constant: 10
            )
        ])

        descriptionTextView.delegate = self

        addDoneToolbar()
    }

    // MARK: - Keyboard Toolbar

    private func addDoneToolbar() {

        let toolbar = UIToolbar()

        toolbar.sizeToFit()

        let flexibleSpace = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )

        let doneButton = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: self,
            action: #selector(dismissKeyboard)
        )

        toolbar.items = [
            flexibleSpace,
            doneButton
        ]

        descriptionTextView.inputAccessoryView = toolbar
        titletextfield.inputAccessoryView = toolbar
    }

    // MARK: - Description Placeholder

    private func updateDescriptionPlaceholderVisibility() {

        descriptionPlaceholderLabel.isHidden =
            !descriptionTextView.text.isEmpty
    }

    // MARK: - Attachment Container

    private func setupAttachmentContainer() {

        containerview.addSubview(
            attachmentPreviewLabel
        )

        containerview.addSubview(
            uploadStatusLabel
        )

        NSLayoutConstraint.activate([

            attachmentPreviewLabel.leadingAnchor.constraint(
                equalTo: containerview.leadingAnchor,
                constant: 12
            ),

            attachmentPreviewLabel.trailingAnchor.constraint(
                equalTo: containerview.trailingAnchor,
                constant: -12
            ),

            attachmentPreviewLabel.topAnchor.constraint(
                equalTo: containerview.topAnchor,
                constant: 8
            ),

            uploadStatusLabel.leadingAnchor.constraint(
                equalTo: containerview.leadingAnchor,
                constant: 12
            ),

            uploadStatusLabel.trailingAnchor.constraint(
                equalTo: containerview.trailingAnchor,
                constant: -12
            ),

            uploadStatusLabel.topAnchor.constraint(
                equalTo: attachmentPreviewLabel.bottomAnchor,
                constant: 4
            ),

            uploadStatusLabel.bottomAnchor.constraint(
                lessThanOrEqualTo: containerview.bottomAnchor,
                constant: -4
            )
        ])
    }

    // MARK: - Attachment UI

    private func updateAttachmentUI() {

        let count =
            selectedAttachments.count +
            uploadedFiles.count

        // No attachment

        if count == 0 {

            AttachmentButton.setTitle(
                nil,
                for: .normal
            )

            AttachmentButton.setImage(
                UIImage(named: "aploadicon"),
                for: .normal
            )

            attachmentPreviewLabel.text =
                "Tap to add attachments"

            attachmentPreviewLabel.textColor =
                .lightGray

            uploadStatusLabel.isHidden = true

            return
        }

        AttachmentButton.setTitle(
            nil,
            for: .normal
        )

        AttachmentButton.setImage(
            UIImage(named: "aploadicon"),
            for: .normal
        )

        attachmentPreviewLabel.textColor =
            .darkGray

        var fileNames: [String] = []

        fileNames.append(
            contentsOf: selectedAttachments.map {
                $0.fileName
            }
        )

        fileNames.append(
            contentsOf: uploadedFiles.map {
                $0.originalFilename
            }
        )

        attachmentPreviewLabel.text =
            fileNames.joined(separator: "\n")
    }

    // MARK: - Keyboard

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Back Button

    @IBAction func backButtonTapped(
        _ sender: UIButton
    ) {

        navigationController?.popViewController(
            animated: true
        )
    }

    // MARK: - Attachment Button

    @IBAction func AttachmentButtonTapped(
        _ sender: UIButton
    ) {

        view.endEditing(true)

        guard !isUploading else {

            showAlert(
                msg: "Please wait, files are being uploaded..."
            )

            return
        }

        let currentCount =
            selectedAttachments.count +
            uploadedFiles.count

        guard currentCount < maxAttachments else {

            showAlert(
                msg: "You can upload a maximum of \(maxAttachments) attachments."
            )

            return
        }

        let alert = UIAlertController(
            title: "Add Attachment",
            message: "Choose an attachment source.",
            preferredStyle: .actionSheet
        )

        // Photo Gallery

        alert.addAction(
            UIAlertAction(
                title: "Photo Gallery",
                style: .default
            ) { [weak self] _ in

                self?.openPhotoGallery()
            }
        )

        // Files

        alert.addAction(
            UIAlertAction(
                title: "Files",
                style: .default
            ) { [weak self] _ in

                self?.openFiles()
            }
        )

        // Remove All

        if !selectedAttachments.isEmpty ||
            !uploadedFiles.isEmpty {

            alert.addAction(
                UIAlertAction(
                    title: "Remove All Attachments",
                    style: .destructive
                ) { [weak self] _ in

                    self?.selectedAttachments.removeAll()
                    self?.uploadedFiles.removeAll()

                    self?.updateAttachmentUI()
                }
            )
        }

        // Cancel

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

        let remainingCount =
            maxAttachments -
            (
                selectedAttachments.count +
                uploadedFiles.count
            )

        guard remainingCount > 0 else {

            showAlert(
                msg: "You can upload a maximum of \(maxAttachments) attachments."
            )

            return
        }

        if #available(iOS 14.0, *) {

            var configuration =
                PHPickerConfiguration()

            configuration.filter =
                .images

            configuration.selectionLimit =
                remainingCount

            let picker =
                PHPickerViewController(
                    configuration: configuration
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

        let remainingCount =
            maxAttachments -
            (
                selectedAttachments.count +
                uploadedFiles.count
            )

        guard remainingCount > 0 else {

            showAlert(
                msg: "You can upload a maximum of \(maxAttachments) attachments."
            )

            return
        }

        let documentPicker: UIDocumentPickerViewController

        if #available(iOS 14.0, *) {

            documentPicker =
                UIDocumentPickerViewController(
                    forOpeningContentTypes: [.item],
                    asCopy: true
                )

        } else {

            documentPicker =
                UIDocumentPickerViewController(
                    documentTypes: ["public.data"],
                    in: .import
                )
        }

        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = true

        present(
            documentPicker,
            animated: true
        )
    }

    // MARK: - Upload Files API

    private func uploadFilesToAPI(
        attachments: [TicketAttachment]
    ) {

        guard !attachments.isEmpty else {
            return
        }

        // IMPORTANT:
        // URL now comes from DEV/PROD environment.
        let currentUploadURL = uploadAPIURL

        guard let url =
            URL(string: currentUploadURL) else {

            showAlert(
                msg: "Invalid upload API URL."
            )

            return
        }

        isUploading = true

        showUploadProgress(
            message: "Uploading \(attachments.count) file(s)..."
        )

        let boundary =
            "Boundary-\(UUID().uuidString)"

        var request =
            URLRequest(url: url)

        request.httpMethod = "POST"

        request.timeoutInterval = 120

        request.setValue(
            "multipart/form-data; boundary=\(boundary)",
            forHTTPHeaderField: "Content-Type"
        )

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Accept"
        )

        // Add authorization

        applyAuthorizationHeader(
            to: &request
        )

        var body = Data()

        // MARK: Multipart Body

        for attachment in attachments {

            var safeFileName =
                attachment.fileName
                    .replacingOccurrences(
                        of: "\"",
                        with: ""
                    )
                    .trimmingCharacters(
                        in: .whitespacesAndNewlines
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

        request.httpBody = body

        // MARK: Debug Logs

        print("====================================")
        print("📤 UPLOAD FILE API")
        print("📤 Environment Base URL: \(PLISTVALUES.baseUrl)")
        print("📤 Upload URL: \(url.absoluteString)")
        print("📤 File Count: \(attachments.count)")
        print("📤 HTTP Method: POST")
        print("📤 Content-Type: multipart/form-data")
        print("📤 Authorization: Attached")
        print("====================================")

        URLSession.shared.dataTask(
            with: request
        ) { [weak self] data, response, error in

            guard let self = self else {
                return
            }

            // MARK: Network Error

            if let error = error {

                DispatchQueue.main.async {

                    self.isUploading = false

                    self.hideUploadProgress()

                    self.showAlert(
                        msg:
                            "Upload failed: \(error.localizedDescription)"
                    )
                }

                return
            }

            // MARK: HTTP Response

            guard let httpResponse =
                response as? HTTPURLResponse else {

                DispatchQueue.main.async {

                    self.isUploading = false

                    self.hideUploadProgress()

                    self.showAlert(
                        msg:
                            "Invalid response from server."
                    )
                }

                return
            }

            // MARK: Response Data

            guard let data = data else {

                DispatchQueue.main.async {

                    self.isUploading = false

                    self.hideUploadProgress()

                    self.showAlert(
                        msg:
                            "No data received from server."
                    )
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
                "📥 UPLOAD API RESPONSE: \(httpResponse.statusCode)"
            )
            print(responseString)
            print("====================================")

            // MARK: Unauthorized

            if httpResponse.statusCode == 401 {

                DispatchQueue.main.async {

                    self.isUploading = false

                    self.hideUploadProgress()

                    print("❌ Upload API returned 401 Unauthorized.")
                    print("❌ Check production access token.")
                    print("❌ Check production upload API URL.")
                    print("❌ Check whether production user exists on backend.")

                    self.showAlert(
                        msg:
                            "Authorization failed. Please login again and try uploading the attachment."
                    )
                }

                return
            }

            // MARK: HTTP Error

            guard (200...299).contains(
                httpResponse.statusCode
            ) else {

                DispatchQueue.main.async {

                    self.isUploading = false

                    self.hideUploadProgress()

                    let message =
                        responseString.isEmpty
                        ? "Upload failed: Server error \(httpResponse.statusCode)"
                        : responseString

                    self.showAlert(
                        msg: message
                    )
                }

                return
            }

            // MARK: Decode Response

            do {

                let uploadResponse =
                    try JSONDecoder().decode(
                        UploadAPIResponse.self,
                        from: data
                    )

                DispatchQueue.main.async {

                    self.isUploading = false

                    self.hideUploadProgress()

                    if uploadResponse.success {

                        guard let files =
                            uploadResponse.data else {

                            self.showAlert(
                                msg:
                                    "Upload succeeded but no file information was returned."
                            )

                            return
                        }

                        // Remove temporary selected files

                        self.selectedAttachments.removeAll()

                        // Add uploaded files

                        for fileData in files {

                            let uploadedFile =
                                fileData.toUploadedFile()

                            self.uploadedFiles.append(
                                uploadedFile
                            )
                        }

                        print("====================================")
                        print("✅ FILE UPLOAD SUCCESS")
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

                        self.showSuccessMessage(
                            msg:
                                "\(files.count) file(s) uploaded successfully!"
                        )

                        self.updateAttachmentUI()

                    } else {

                        self.showAlert(
                            msg:
                                uploadResponse.description
                        )
                    }
                }

            } catch {

                print(
                    "❌ Upload response decoding failed:",
                    error.localizedDescription
                )

                DispatchQueue.main.async {

                    self.isUploading = false

                    self.hideUploadProgress()

                    self.showAlert(
                        msg:
                            "Failed to parse upload response: \(error.localizedDescription)"
                    )
                }
            }

        }.resume()
    }

    // MARK: - Upload Progress

    private func showUploadProgress(
        message: String
    ) {

        uploadStatusLabel.text =
            "\(message)\nPlease wait..."

        uploadStatusLabel.textColor =
            .systemBlue

        uploadStatusLabel.isHidden =
            false

        showLoader()
    }

    private func hideUploadProgress() {

        uploadStatusLabel.isHidden =
            true

        hideLoader()
    }

    private func showSuccessMessage(
        msg: String
    ) {

        uploadStatusLabel.text =
            msg

        uploadStatusLabel.textColor =
            .systemGreen

        uploadStatusLabel.isHidden =
            false

        DispatchQueue.main.asyncAfter(
            deadline: .now() + 3
        ) { [weak self] in

            UIView.animate(
                withDuration: 0.3
            ) {

                self?.uploadStatusLabel.isHidden =
                    true
            }
        }
    }

    // MARK: - Submit Query

    @IBAction func SubmitqueryButtonTapped(
        _ sender: UIButton
    ) {

        view.endEditing(true)

        guard let title =
            titletextfield.text?
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                ),
              !title.isEmpty else {

            showAlert(
                msg:
                    "Please enter a query title."
            )

            return
        }

        let description =
            descriptionText

        guard !description.isEmpty else {

            showAlert(
                msg:
                    "Please enter a description."
            )

            return
        }

        guard !isUploading else {

            showAlert(
                msg:
                    "Please wait for file uploads to complete."
            )

            return
        }

        postTicketAPI(
            title: title,
            description: description
        )
    }

    // MARK: - Create Ticket API

    private func postTicketAPI(
        title: String,
        description: String
    ) {

        guard let url =
            URL(string: API.CREATE_TICKET) else {

            showAlert(
                msg:
                    "Invalid API URL."
            )

            return
        }

        showLoader()

        sendJSONTicketRequest(
            url: url,
            title: title,
            description: description
        )
    }

    // MARK: - JSON Request

    private func sendJSONTicketRequest(
        url: URL,
        title: String,
        description: String
    ) {

        var request =
            URLRequest(url: url)

        request.httpMethod =
            "POST"

        request.timeoutInterval =
            60

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Accept"
        )

        applyAuthorizationHeader(
            to: &request
        )

        var parameters: [String: Any] = [

            "title": title,

            "subject": title,

            "description": description,

            "desc": description,

            "message": description,

            "query": description
        ]

        // MARK: Add Uploaded Files

        if !uploadedFiles.isEmpty {

            let fileURLs =
                uploadedFiles.map {
                    $0.fileUrl
                }

            parameters["attachments"] =
                fileURLs

            parameters["files"] =
                fileURLs

            parameters["file_urls"] =
                fileURLs
        }

        do {

            request.httpBody =
                try JSONSerialization.data(
                    withJSONObject: parameters,
                    options: []
                )

        } catch {

            hideLoader()

            showAlert(
                msg:
                    "Unable to prepare request: \(error.localizedDescription)"
            )

            return
        }

        print("====================================")
        print("📤 CREATE TICKET API")
        print("📤 Ticket URL: \(url.absoluteString)")
        print("📤 Uploaded Attachments: \(uploadedFiles.count)")
        print("📤 Parameters: \(parameters)")
        print("====================================")

        performTicketRequest(
            request
        )
    }

    // MARK: - Network Execution

    private func performTicketRequest(
        _ request: URLRequest
    ) {

        URLSession.shared.dataTask(
            with: request
        ) { [weak self] data, response, error in

            guard let self = self else {
                return
            }

            // MARK: Network Error

            if let error = error {

                DispatchQueue.main.async {

                    self.hideLoader()

                    self.showAlert(
                        msg:
                            error.localizedDescription
                    )
                }

                return
            }

            // MARK: Invalid Response

            guard let httpResponse =
                response as? HTTPURLResponse else {

                DispatchQueue.main.async {

                    self.hideLoader()

                    self.showAlert(
                        msg:
                            "Invalid response from server."
                    )
                }

                return
            }

            // MARK: No Data

            guard let data = data else {

                DispatchQueue.main.async {

                    self.hideLoader()

                    self.showAlert(
                        msg:
                            "No data received from server."
                    )
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
                "📥 CREATE TICKET RESPONSE: \(httpResponse.statusCode)"
            )
            print(responseString)
            print("====================================")

            // MARK: Unauthorized

            if httpResponse.statusCode == 401 {

                DispatchQueue.main.async {

                    self.hideLoader()

                    self.showAlert(
                        msg:
                            "Your session has expired. Please login again."
                    )
                }

                return
            }

            // MARK: HTTP Error

            guard (200...299).contains(
                httpResponse.statusCode
            ) else {

                let errorMessage =
                    responseString.isEmpty
                    ? "Server error: \(httpResponse.statusCode)"
                    : responseString

                DispatchQueue.main.async {

                    self.hideLoader()

                    self.showAlert(
                        msg:
                            errorMessage
                    )
                }

                return
            }

            // MARK: Decode Response

            do {

                let apiResponse =
                    try JSONDecoder().decode(
                        APIResponse<TicketData>.self,
                        from: data
                    )

                DispatchQueue.main.async {

                    self.hideLoader()

                    if apiResponse.success {

                        let createdTicketId =
                            apiResponse.data?.id

                        print(
                            "✅ Created Ticket ID:",
                            createdTicketId ??
                            "Not returned by API"
                        )

                        self.navigateToSuccessScreen(
                            ticketId:
                                createdTicketId
                        )

                    } else {

                        self.showAlert(
                            msg:
                                apiResponse.description
                        )
                    }
                }

            } catch {

                print(
                    "❌ Ticket response decoding failed:",
                    error.localizedDescription
                )

                DispatchQueue.main.async {

                    self.hideLoader()

                    self.showAlert(
                        msg:
                            "Response decoding failed: \(error.localizedDescription)"
                    )
                }
            }
        }.resume()
    }

    // MARK: - Authorization Header

    private func applyAuthorizationHeader(
        to request: inout URLRequest
    ) {

        // Try all possible token keys used by the project

        let possibleKeys = [
            "ACCESSTOKEN",
            "accessToken",
            "access_token",
            "token"
        ]

        var token: String?

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

                    token = cleaned

                    print(
                        "🟢 Access token found using key: \(key)"
                    )

                    break
                }
            }
        }

        guard let token = token else {

            print(
                "❌ Authorization token was NOT found."
            )

            return
        }

        let authorizationValue: String

        if token.lowercased().hasPrefix("bearer ") {

            authorizationValue =
                token

        } else if token.lowercased().hasPrefix("token ") {

            authorizationValue =
                token

        } else {

            authorizationValue =
                "Bearer \(token)"
        }

        request.setValue(
            authorizationValue,
            forHTTPHeaderField: "Authorization"
        )

        print(
            "🟢 Authorization header attached."
        )
    }

    // MARK: - Navigation

    private func navigateToSuccessScreen(
        ticketId: String?
    ) {

        let storyboard =
            UIStoryboard(
                name: "Main",
                bundle: nil
            )

        guard let querySubmittedVC =
            storyboard.instantiateViewController(
                withIdentifier:
                    "QuerysubmittedVC"
            ) as? QuerysubmittedVC else {

            print(
                "❌ QuerysubmittedVC not found in Main.storyboard."
            )

            return
        }

        querySubmittedVC.ticketId =
            ticketId

        // Clear title

        titletextfield.text =
            ""

        // Clear old text field

        Descriptiontextfield.text =
            ""

        // Clear text view

        descriptionTextView.text =
            ""

        updateDescriptionPlaceholderVisibility()

        // Clear attachments

        selectedAttachments.removeAll()
        uploadedFiles.removeAll()

        updateAttachmentUI()

        navigationController?.pushViewController(
            querySubmittedVC,
            animated: true
        )
    }

    // MARK: - Attachment Helpers

    private func appendAttachments(
        _ attachments: [TicketAttachment]
    ) {

        guard !attachments.isEmpty else {
            return
        }

        let remainingCount =
            maxAttachments -
            (
                selectedAttachments.count +
                uploadedFiles.count
            )

        guard remainingCount > 0 else {

            showAlert(
                msg:
                    "You can upload only \(maxAttachments) attachments."
            )

            return
        }

        let allowedAttachments =
            Array(
                attachments.prefix(
                    remainingCount
                )
            )

        selectedAttachments.append(
            contentsOf:
                allowedAttachments
        )

        updateAttachmentUI()

        // Start upload immediately

        uploadFilesToAPI(
            attachments:
                allowedAttachments
        )

        if attachments.count >
            allowedAttachments.count {

            showAlert(
                msg:
                    "Only \(maxAttachments) attachments can be selected."
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
            return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"

        case "xls":
            return "application/vnd.ms-excel"

        case "xlsx":
            return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"

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
}

// MARK: - UITextViewDelegate

extension RaiseaQueryVC: UITextViewDelegate {

    func textViewDidChange(
        _ textView: UITextView
    ) {

        updateDescriptionPlaceholderVisibility()
    }

    func textViewDidBeginEditing(
        _ textView: UITextView
    ) {

        updateDescriptionPlaceholderVisibility()
    }

    func textViewDidEndEditing(
        _ textView: UITextView
    ) {

        updateDescriptionPlaceholderVisibility()
    }
}

// MARK: - PHPickerViewControllerDelegate

@available(iOS 14.0, *)
extension RaiseaQueryVC: PHPickerViewControllerDelegate {

    func picker(
        _ picker: PHPickerViewController,
        didFinishPicking results: [PHPickerResult]
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
            [TicketAttachment] = []

        var skippedLargeImage =
            false

        for (index, result) in
            results.enumerated() {

            group.enter()

            result.itemProvider.loadObject(
                ofClass: UIImage.self
            ) { [weak self] object, _ in

                defer {
                    group.leave()
                }

                guard let self = self,
                      let image = object as? UIImage,
                      let imageData =
                        image.jpegData(
                            compressionQuality: 0.75
                        ) else {

                    return
                }

                guard imageData.count <=
                        self.maxFileSizeInBytes else {

                    lock.lock()

                    skippedLargeImage = true

                    lock.unlock()

                    return
                }

                let attachment =
                    TicketAttachment(
                        data:
                            imageData,

                        fileName:
                            "Photo_\(index + 1)_\(Int(Date().timeIntervalSince1970)).jpg",

                        mimeType:
                            "image/jpeg"
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

                self.appendAttachments(
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

extension RaiseaQueryVC:
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate {

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info:
            [UIImagePickerController.InfoKey: Any]
    ) {

        picker.dismiss(
            animated: true
        )

        guard let image =
                info[.originalImage] as? UIImage,
              let imageData =
                image.jpegData(
                    compressionQuality: 0.75
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
            TicketAttachment(
                data:
                    imageData,

                fileName:
                    "Photo_\(UUID().uuidString).jpg",

                mimeType:
                    "image/jpeg"
            )

        appendAttachments(
            [attachment]
        )
    }

    func imagePickerControllerDidCancel(
        _ picker: UIImagePickerController
    ) {

        picker.dismiss(
            animated: true
        )
    }
}

// MARK: - UIDocumentPickerDelegate

extension RaiseaQueryVC:
    UIDocumentPickerDelegate {

    func documentPicker(
        _ controller: UIDocumentPickerViewController,
        didPickDocumentsAt urls: [URL]
    ) {

        guard !urls.isEmpty else {
            return
        }

        let availableSlots =
            maxAttachments -
            (
                selectedAttachments.count +
                uploadedFiles.count
            )

        guard availableSlots > 0 else {

            showAlert(
                msg:
                    "You can upload a maximum of \(maxAttachments) attachments."
            )

            return
        }

        let selectedURLs =
            Array(
                urls.prefix(
                    availableSlots
                )
            )

        DispatchQueue.global(
            qos: .userInitiated
        ).async { [weak self] in

            guard let self = self else {
                return
            }

            var attachments:
                [TicketAttachment] = []

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
                            contentsOf: url,
                            options: [.mappedIfSafe]
                        )

                    // File size validation

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

                    let attachment =
                        TicketAttachment(
                            data:
                                data,

                            fileName:
                                fileName,

                            mimeType:
                                self.mimeType(
                                    for:
                                        url.pathExtension
                                )
                        )

                    attachments.append(
                        attachment
                    )

                } catch {

                    print(
                        "❌ Unable to read selected file:",
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

                    self.appendAttachments(
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
        _ controller: UIDocumentPickerViewController
    ) {

        print(
            "Document picker cancelled."
        )
    }
}
