//
//  RaiseaQueryVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 20/08/26.
//

import UIKit
import PhotosUI
import UniformTypeIdentifiers

// MARK: - Attachment Model

private struct TicketAttachment {
    let data: Data
    let fileName: String
    let mimeType: String
}

// MARK: - Upload Error

private enum TicketUploadError: LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL."
        case .invalidResponse:
            return "Invalid response from server."
        case .serverError(let message):
            return message
        }
    }
}

// MARK: - Data Helper

private extension Data {
    mutating func appendMultipartString(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

// MARK: - Raise Query VC

class RaiseaQueryVC: UIViewController {

    @IBOutlet weak var containerview: UIView!
    @IBOutlet weak var AttachmentButton: UIButton!
    @IBOutlet weak var Descriptiontextfield: UITextField!
    @IBOutlet weak var titletextfield: UITextField!
    @IBOutlet weak var Attechmentsbackgoundview: UIView!
    @IBOutlet weak var SumitqueryButton: UIButton!
    @IBOutlet weak var backButton: UIButton!

    // MARK: - Properties

    private var selectedAttachments: [TicketAttachment] = []

    private let maxAttachments = 5
    private let maxFileSizeInBytes = 10 * 1024 * 1024 // 10 MB

    /*
     Backend file parameter name.

     Common Django DRF names:
     "attachments"
     "attachments[]"
     "attachment"

     Change this only if backend gives another key.
     */
    private let attachmentFieldName = "attachments"

    private let attachmentPreviewLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .darkGray
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    /*
     A UITextField can NEVER wrap text, it is single line by design.

     So the storyboard Descriptiontextfield is hidden and this
     multi line UITextView is placed exactly on top of it,
     using the same constraints.

     No storyboard change is required.
     */
    private func setupAttachmentBorder() {

        let borderLayer = CAShapeLayer()

        borderLayer.strokeColor = UIColor.lightGray.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor

        // Dotted border
        borderLayer.lineDashPattern = [2, 4]

        borderLayer.lineWidth = 1

        borderLayer.path = UIBezierPath(
            roundedRect: Attechmentsbackgoundview.bounds,
            cornerRadius: 8
        ).cgPath

        Attechmentsbackgoundview.layer.addSublayer(borderLayer)
    }
    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.textColor = .black
        textView.backgroundColor = .clear
        textView.isScrollEnabled = true
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8)
        textView.autocorrectionType = .default
        textView.returnKeyType = .default
        return textView
    }()

    private let descriptionPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Describe your query in detail..."
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = UIColor.lightGray
        label.numberOfLines = 0
        return label
    }()

    /// Convenience accessor for the typed description
    private var descriptionText: String {
        descriptionTextView.text
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupDescriptionTextView()
        setupAttachmentContainer()
        updateAttachmentUI()

        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )

        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    // MARK: - Description Text View Setup

    private func setupDescriptionTextView() {

        guard let parentView = Descriptiontextfield.superview else {
            print("⚠️ Descriptiontextfield has no superview.")
            return
        }

        // Copy visual style from the storyboard text field
        descriptionTextView.backgroundColor = Descriptiontextfield.backgroundColor
        descriptionTextView.layer.cornerRadius = Descriptiontextfield.layer.cornerRadius
        descriptionTextView.layer.borderWidth = Descriptiontextfield.layer.borderWidth
        descriptionTextView.layer.borderColor = Descriptiontextfield.layer.borderColor
        descriptionTextView.clipsToBounds = true

        if let existingFont = Descriptiontextfield.font {
            descriptionTextView.font = existingFont
            descriptionPlaceholderLabel.font = existingFont
        }

        if let existingPlaceholder = Descriptiontextfield.placeholder,
           !existingPlaceholder.isEmpty {
            descriptionPlaceholderLabel.text = existingPlaceholder
        }

        // Hide the single line field, keep it for layout reference only
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

        // Placeholder inside the text view
        descriptionTextView.addSubview(descriptionPlaceholderLabel)

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

    /// A multi line text view has no Return key to dismiss with,
    /// so a Done button is added above the keyboard.
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

        toolbar.items = [flexibleSpace, doneButton]

        descriptionTextView.inputAccessoryView = toolbar
        titletextfield.inputAccessoryView = toolbar
    }

    private func updateDescriptionPlaceholderVisibility() {
        descriptionPlaceholderLabel.isHidden = !descriptionTextView.text.isEmpty
    }

    // MARK: - UI Setup

    private func setupAttachmentContainer() {
        containerview.addSubview(attachmentPreviewLabel)

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
            attachmentPreviewLabel.bottomAnchor.constraint(
                equalTo: containerview.bottomAnchor,
                constant: -8
            )
        ])
    }

    private func updateAttachmentUI() {
        let count = selectedAttachments.count

        // Remove title and set image
        AttachmentButton.setTitle(nil, for: .normal)
        AttachmentButton.setImage(UIImage(named: "aploadicon"), for: .normal)

        if count == 0 {
            attachmentPreviewLabel.text = ""
        } else {
            let fileNames = selectedAttachments
                .enumerated()
                .map { index, attachment in
                    "\(index + 1). \(attachment.fileName)"
                }
                .joined(separator: "\n")

            attachmentPreviewLabel.text = fileNames
        }
    }

    // MARK: - Keyboard

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Back Button

    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Attachment Button

    @IBAction func AttachmentButtonTapped(_ sender: UIButton) {
        view.endEditing(true)

        let alert = UIAlertController(
            title: "Add Attachment",
            message: "Choose an attachment source.",
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

        if !selectedAttachments.isEmpty {
            alert.addAction(
                UIAlertAction(
                    title: "Remove All Attachments",
                    style: .destructive
                ) { [weak self] _ in
                    self?.selectedAttachments.removeAll()
                    self?.updateAttachmentUI()
                }
            )
        }

        alert.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel
            )
        )

        // Required for iPad action sheet
        if let popover = alert.popoverPresentationController {
            popover.sourceView = AttachmentButton
            popover.sourceRect = AttachmentButton.bounds
        }

        present(alert, animated: true)
    }

    // MARK: - Photo Gallery

    private func openPhotoGallery() {
        let remainingCount = maxAttachments - selectedAttachments.count

        guard remainingCount > 0 else {
            showAlert(msg: "You can upload a maximum of \(maxAttachments) attachments.")
            return
        }

        if #available(iOS 14.0, *) {
            var configuration = PHPickerConfiguration()
            configuration.filter = .images
            configuration.selectionLimit = remainingCount

            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self

            present(picker, animated: true)
        } else {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .photoLibrary
            imagePicker.delegate = self
            imagePicker.allowsEditing = false

            present(imagePicker, animated: true)
        }
    }

    // MARK: - Files Picker

    private func openFiles() {
        let remainingCount = maxAttachments - selectedAttachments.count

        guard remainingCount > 0 else {
            showAlert(msg: "You can upload a maximum of \(maxAttachments) attachments.")
            return
        }

        let documentPicker: UIDocumentPickerViewController

        if #available(iOS 14.0, *) {
            documentPicker = UIDocumentPickerViewController(
                forOpeningContentTypes: [.item],
                asCopy: true
            )
        } else {
            documentPicker = UIDocumentPickerViewController(
                documentTypes: ["public.data"],
                in: .import
            )
        }

        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = true

        present(documentPicker, animated: true)
    }

    // MARK: - Submit Query

    @IBAction func SubmitqueryButtonTapped(_ sender: UIButton) {
        view.endEditing(true)

        guard let title = titletextfield.text?
            .trimmingCharacters(in: .whitespacesAndNewlines),
              !title.isEmpty else {
            showAlert(msg: "Please enter a query title.")
            return
        }

        let description = descriptionText

        guard !description.isEmpty else {
            showAlert(msg: "Please enter a description.")
            return
        }

        postTicketAPI(title: title, description: description)
    }

    // MARK: - Create Ticket API (Router)

    /*
     Attachments are OPTIONAL.

     No attachments  -> plain JSON request (application/json)
     With attachments -> multipart/form-data request

     Reason:
     Sending an empty multipart body caused this backend error:
     "Missing filename. Request should include a Content-Disposition
      header with a filename parameter."

     A multipart request is only valid here when at least one real file part exists.
     */
    private func postTicketAPI(title: String, description: String) {
        guard let url = URL(string: API.CREATE_TICKET) else {
            showAlert(msg: "Invalid API URL.")
            return
        }

        showLoader()

        if selectedAttachments.isEmpty {
            sendJSONTicketRequest(
                url: url,
                title: title,
                description: description
            )
        } else {
            sendMultipartTicketRequest(
                url: url,
                title: title,
                description: description
            )
        }
    }

    // MARK: - JSON Request (No Attachments)

    private func sendJSONTicketRequest(
        url: URL,
        title: String,
        description: String
    ) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 60

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Accept"
        )

        applyAuthorizationHeader(to: &request)

        let parameters: [String: Any] = [
            "title": title,
            "subject": title,
            "description": description,
            "desc": description,
            "message": description,
            "query": description
        ]

        do {
            request.httpBody = try JSONSerialization.data(
                withJSONObject: parameters,
                options: []
            )
        } catch {
            hideLoader()
            showAlert(msg: "Unable to prepare request: \(error.localizedDescription)")
            return
        }

        print("📤 Sending ticket as JSON (no attachments).")

        performTicketRequest(request, hadAttachments: false)
    }

    // MARK: - Multipart Request (With Attachments)

    private func sendMultipartTicketRequest(
        url: URL,
        title: String,
        description: String
    ) {
        let boundary = "Boundary-\(UUID().uuidString)"

        var request = URLRequest(url: url)
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

        applyAuthorizationHeader(to: &request)

        var body = Data()

        let formFields: [(String, String)] = [
            ("title", title),
            ("subject", title),
            ("description", description),
            ("desc", description),
            ("message", description),
            ("query", description)
        ]

        for field in formFields {
            appendFormField(
                name: field.0,
                value: field.1,
                to: &body,
                boundary: boundary
            )
        }

        for attachment in selectedAttachments {
            appendFile(
                attachment,
                fieldName: attachmentFieldName,
                to: &body,
                boundary: boundary
            )
        }

        body.appendMultipartString("--\(boundary)--\r\n")
        request.httpBody = body

        print("📤 Sending ticket as multipart with \(selectedAttachments.count) attachment(s).")

        performTicketRequest(request, hadAttachments: true)
    }

    // MARK: - Shared Network Execution

    private func performTicketRequest(
        _ request: URLRequest,
        hadAttachments: Bool
    ) {
        URLSession.shared.dataTask(
            with: request
        ) { [weak self] data, response, error in

            guard let self = self else { return }

            DispatchQueue.main.async {
                self.hideLoader()
            }

            if let error = error {
                DispatchQueue.main.async {
                    self.showAlert(msg: error.localizedDescription)
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    self.showAlert(msg: TicketUploadError.invalidResponse.localizedDescription)
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.showAlert(msg: "No data received from server.")
                }
                return
            }

            let responseString = String(data: data, encoding: .utf8) ?? ""

            print("CREATE TICKET RESPONSE (\(httpResponse.statusCode)):")
            print(responseString)

            // Session expired
            if httpResponse.statusCode == 401 {
                DispatchQueue.main.async {
                    self.showAlert(msg: "Your session has expired. Please login again.")
                }
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                var errorMessage = responseString.isEmpty
                    ? "Server error."
                    : responseString

                // Friendly message if backend cannot accept multipart uploads
                if hadAttachments,
                   responseString.lowercased().contains("missing filename") {
                    errorMessage = "This server is not accepting file uploads on this endpoint yet. Please submit the query without attachments."
                }

                DispatchQueue.main.async {
                    self.showAlert(msg: errorMessage)
                }
                return
            }

            do {
                let apiResponse = try JSONDecoder().decode(
                    APIResponse<TicketData>.self,
                    from: data
                )

                DispatchQueue.main.async {
                    if apiResponse.success {
                        let createdTicketId = apiResponse.data?.id

                        print("Created Ticket ID:", createdTicketId ?? "Not returned by API")

                        self.navigateToSuccessScreen(
                            ticketId: createdTicketId
                        )
                    } else {
                        self.showAlert(msg: apiResponse.description)
                    }
                }

            } catch {
                DispatchQueue.main.async {
                    self.showAlert(
                        msg: "Response decoding failed: \(error.localizedDescription)"
                    )
                }
            }

        }.resume()
    }

    // MARK: - Multipart Form Helpers

    private func appendFormField(
        name: String,
        value: String,
        to body: inout Data,
        boundary: String
    ) {
        body.appendMultipartString("--\(boundary)\r\n")
        body.appendMultipartString(
            "Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n"
        )
        body.appendMultipartString("\(value)\r\n")
    }

    private func appendFile(
        _ attachment: TicketAttachment,
        fieldName: String,
        to body: inout Data,
        boundary: String
    ) {
        // Never allow an empty filename, it triggers a DRF parser error
        var safeFileName = attachment.fileName
            .replacingOccurrences(of: "\"", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if safeFileName.isEmpty {
            safeFileName = "attachment_\(UUID().uuidString).dat"
        }

        body.appendMultipartString("--\(boundary)\r\n")

        body.appendMultipartString(
            "Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(safeFileName)\"\r\n"
        )

        body.appendMultipartString(
            "Content-Type: \(attachment.mimeType)\r\n\r\n"
        )

        body.append(attachment.data)
        body.appendMultipartString("\r\n")
    }

    // MARK: - Authorization Header

    private func applyAuthorizationHeader(to request: inout URLRequest) {
        /*
         Token is saved by the Login flow under the key "ACCESSTOKEN".

         Confirmed from DBManager.deleteUser():
             UserDefaults.standard.removeObject(forKey: "ACCESSTOKEN")
             UserDefaults.standard.removeObject(forKey: "REFRESHTOKEN")

         UserDefaults keys are case-sensitive.
         */

        let token = UserDefaults.standard.string(forKey: "ACCESSTOKEN")
            ?? UserDefaults.standard.string(forKey: "accessToken")
            ?? UserDefaults.standard.string(forKey: "token")

        guard let token = token,
              !token.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("⚠️ Authorization token was not found under key ACCESSTOKEN.")
            return
        }

        let cleanToken = token.trimmingCharacters(in: .whitespacesAndNewlines)

        let authorizationValue: String

        if cleanToken.lowercased().hasPrefix("bearer ")
            || cleanToken.lowercased().hasPrefix("token ") {
            authorizationValue = cleanToken
        } else {
            authorizationValue = "Bearer \(cleanToken)"
        }

        request.setValue(
            authorizationValue,
            forHTTPHeaderField: "Authorization"
        )

        print("🟢 Authorization header attached.")
    }

    // MARK: - Navigation

    private func navigateToSuccessScreen(ticketId: String?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        guard let querySubmittedVC = storyboard.instantiateViewController(
            withIdentifier: "QuerysubmittedVC"
        ) as? QuerysubmittedVC else {
            return
        }

        // Pass created ticket ID to QuerysubmittedVC
        querySubmittedVC.ticketId = ticketId

        titletextfield.text = ""
        Descriptiontextfield.text = ""
        descriptionTextView.text = ""
        updateDescriptionPlaceholderVisibility()

        selectedAttachments.removeAll()
        updateAttachmentUI()

        navigationController?.pushViewController(
            querySubmittedVC,
            animated: true
        )
    }

    // MARK: - Attachment Helpers

    private func appendAttachments(_ attachments: [TicketAttachment]) {
        let remainingCount = maxAttachments - selectedAttachments.count

        guard remainingCount > 0 else {
            showAlert(msg: "You can upload only \(maxAttachments) attachments.")
            return
        }

        let allowedAttachments = Array(attachments.prefix(remainingCount))
        selectedAttachments.append(contentsOf: allowedAttachments)

        updateAttachmentUI()

        if attachments.count > allowedAttachments.count {
            showAlert(
                msg: "Only \(maxAttachments) attachments can be selected."
            )
        }
    }

    private func mimeType(for fileExtension: String) -> String {
        switch fileExtension.lowercased() {
        case "jpg", "jpeg":
            return "image/jpeg"

        case "png":
            return "image/png"

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

        default:
            return "application/octet-stream"
        }
    }
}

// MARK: - UITextViewDelegate

extension RaiseaQueryVC: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        updateDescriptionPlaceholderVisibility()
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        updateDescriptionPlaceholderVisibility()
    }

    func textViewDidEndEditing(_ textView: UITextView) {
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
        picker.dismiss(animated: true)

        guard !results.isEmpty else { return }

        showLoader()

        let group = DispatchGroup()
        let lock = NSLock()

        var attachments: [TicketAttachment] = []
        var skippedLargeImage = false

        for (index, result) in results.enumerated() {
            group.enter()

            result.itemProvider.loadObject(
                ofClass: UIImage.self
            ) { [weak self] object, _ in

                defer {
                    group.leave()
                }

                guard let self = self,
                      let image = object as? UIImage,
                      let imageData = image.jpegData(compressionQuality: 0.75) else {
                    return
                }

                guard imageData.count <= self.maxFileSizeInBytes else {
                    lock.lock()
                    skippedLargeImage = true
                    lock.unlock()
                    return
                }

                let attachment = TicketAttachment(
                    data: imageData,
                    fileName: "Photo_\(index + 1)_\(Int(Date().timeIntervalSince1970)).jpg",
                    mimeType: "image/jpeg"
                )

                lock.lock()
                attachments.append(attachment)
                lock.unlock()
            }
        }

        group.notify(queue: .main) {
            self.hideLoader()

            if !attachments.isEmpty {
                self.appendAttachments(attachments)
            }

            if skippedLargeImage {
                self.showAlert(
                    msg: "One or more images were skipped because file size exceeds 10 MB."
                )
            }
        }
    }
}

// MARK: - UIImagePickerControllerDelegate
// Used only for iOS versions lower than iOS 14.

extension RaiseaQueryVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        picker.dismiss(animated: true)

        guard let image = info[.originalImage] as? UIImage,
              let imageData = image.jpegData(compressionQuality: 0.75) else {
            return
        }

        guard imageData.count <= maxFileSizeInBytes else {
            showAlert(msg: "Selected image exceeds maximum file size of 10 MB.")
            return
        }

        let attachment = TicketAttachment(
            data: imageData,
            fileName: "Photo_\(UUID().uuidString).jpg",
            mimeType: "image/jpeg"
        )

        appendAttachments([attachment])
    }

    func imagePickerControllerDidCancel(
        _ picker: UIImagePickerController
    ) {
        picker.dismiss(animated: true)
    }
}

// MARK: - UIDocumentPickerDelegate

extension RaiseaQueryVC: UIDocumentPickerDelegate {

    func documentPicker(
        _ controller: UIDocumentPickerViewController,
        didPickDocumentsAt urls: [URL]
    ) {
        guard !urls.isEmpty else { return }

        showLoader()

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            var attachments: [TicketAttachment] = []
            var skippedFileCount = 0

            for url in urls {
                let canAccess = url.startAccessingSecurityScopedResource()

                defer {
                    if canAccess {
                        url.stopAccessingSecurityScopedResource()
                    }
                }

                do {
                    let data = try Data(
                        contentsOf: url,
                        options: [.mappedIfSafe]
                    )

                    if data.count > self.maxFileSizeInBytes {
                        skippedFileCount += 1
                        continue
                    }

                    var fileName = url.lastPathComponent
                        .trimmingCharacters(in: .whitespacesAndNewlines)

                    if fileName.isEmpty {
                        fileName = "File_\(UUID().uuidString).dat"
                    }

                    let mimeType = self.mimeType(
                        for: url.pathExtension
                    )

                    let attachment = TicketAttachment(
                        data: data,
                        fileName: fileName,
                        mimeType: mimeType
                    )

                    attachments.append(attachment)

                } catch {
                    print(
                        "Unable to read selected file:",
                        error.localizedDescription
                    )
                    skippedFileCount += 1
                }
            }

            DispatchQueue.main.async {
                self.hideLoader()

                if !attachments.isEmpty {
                    self.appendAttachments(attachments)
                }

                if skippedFileCount > 0 {
                    self.showAlert(
                        msg: "\(skippedFileCount) file(s) could not be attached. Maximum allowed file size is 10 MB."
                    )
                }
            }
        }
    }

    func documentPickerWasCancelled(
        _ controller: UIDocumentPickerViewController
    ) {
        print("Document picker cancelled.")
    }
}
