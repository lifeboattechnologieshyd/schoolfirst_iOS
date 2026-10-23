//
//  StudentprofileVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 21/05/26.
//

import UIKit
import QuickLook

class StudentprofileVC: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var NotificationButton: UIButton!
    @IBOutlet weak var BackButton: UIButton!
    @IBOutlet weak var TableView: UITableView!

    // Top View / Staff
    @IBOutlet weak var topVw: UIView!

    // MARK: - Properties

    let cellIdentifier = "StudentdetailsTableViewCell"
    let documentCellIdentifier = "DocumentsTableViewCell2"

    private var profileData: StudentProfileData?
    private var loadedStudentId: String = ""
    private var previewFileURL: URL?

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        setupNotificationButton()
        setupBackButton()
        setupTopView()

        fetchStudentProfile()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(
            true,
            animated: animated
        )

        // Dynamic reload on Student Switch
        let currentStudentId = UserManager.shared.resolvedStudentID
        if currentStudentId != loadedStudentId && !currentStudentId.isEmpty {
            print("🔄 Student changed to: \(currentStudentId). Fetching new profile...")
            fetchStudentProfile()
        }
    }

    // MARK: - TableView Setup

    private func setupTableView() {
        TableView.delegate = self
        TableView.dataSource = self

        TableView.register(
            UINib(nibName: cellIdentifier, bundle: nil),
            forCellReuseIdentifier: cellIdentifier
        )

        TableView.register(
            UINib(nibName: documentCellIdentifier, bundle: nil),
            forCellReuseIdentifier: documentCellIdentifier
        )

        TableView.separatorStyle = .none
        TableView.showsVerticalScrollIndicator = false

        // Disable cell selection/tapping
        TableView.allowsSelection = false
    }

    // MARK: - Top View / Staff Setup

    private func setupTopView() {
        topVw.isHidden = false
    }

    // MARK: - Setup Notification Button

    private func setupNotificationButton() {
        NotificationButton.addTarget(
            self,
            action: #selector(notificationButtonTapped),
            for: .touchUpInside
        )
    }

    // MARK: - Setup Back Button

    private func setupBackButton() {
        BackButton.addTarget(
            self,
            action: #selector(backButtonTapped),
            for: .touchUpInside
        )
    }

    // MARK: - Back Button Action

    @objc private func backButtonTapped() {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    // MARK: - Notification Button Action

    @objc private func notificationButtonTapped() {
        let storyboard = UIStoryboard(
            name: "Main",
            bundle: nil
        )

        if let notificationVC = storyboard.instantiateViewController(
            withIdentifier: "NotificationVC"
        ) as? NotificationVC {

            notificationVC.hidesBottomBarWhenPushed = true

            if let nav = navigationController {
                nav.setNavigationBarHidden(
                    true,
                    animated: false
                )

                nav.pushViewController(
                    notificationVC,
                    animated: true
                )
            } else {
                notificationVC.modalPresentationStyle = .fullScreen

                present(
                    notificationVC,
                    animated: true
                )
            }
        }
    }

    // MARK: - API: Fetch Student Profile

    private func fetchStudentProfile() {
        let studentId = UserManager.shared.resolvedStudentID
        let schoolId = UserManager.shared.resolvedSchoolID

        guard !studentId.isEmpty, !schoolId.isEmpty else {
            print("❌ Profile: Missing schoolId or studentId")
            return
        }

        let requestURL = API.STUDENT_PROFILE + studentId

        NetworkManager.shared.request(
            urlString: requestURL,
            method: .GET,
            requiresAuth: true,
            parameters: nil,
            headers: ["X-School-Id": schoolId]
        ) { [weak self] (result: Result<APIResponse<StudentProfileData>, NetworkError>) in
            guard let self = self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success, let data = response.data {
                        self.profileData = data
                        self.loadedStudentId = studentId

                        print("✅ Student Profile parsed successfully for \(data.name)")

                        // Save photo URL for this specific student ID.
                        if let photoUrl = data.photoUrl,
                           !photoUrl.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            UserDefaults.standard.set(
                                photoUrl,
                                forKey: "STUDENT_PHOTO_URL_\(studentId)"
                            )

                            if studentId == UserManager.shared.resolvedStudentID {
                                UserDefaults.standard.set(
                                    photoUrl,
                                    forKey: "STUDENT_PHOTO_URL"
                                )
                            }

                            print(
                                "💾 Saved STUDENT_PHOTO_URL for \(data.name) (\(studentId)):",
                                photoUrl
                            )
                        } else {
                            UserDefaults.standard.removeObject(
                                forKey: "STUDENT_PHOTO_URL_\(studentId)"
                            )

                            if studentId == UserManager.shared.resolvedStudentID {
                                UserDefaults.standard.removeObject(
                                    forKey: "STUDENT_PHOTO_URL"
                                )
                            }
                        }
                    } else {
                        self.profileData = nil
                    }

                case .failure(let error):
                    print("❌ Student Profile API request failed: \(error)")
                    self.profileData = nil
                }

                self.TableView.reloadData()
            }
        }
    }

    // MARK: - Document Actions

    private func remoteURL(for document: StudentDocument) -> URL? {
        guard let urlString = document.fileUrl?
            .trimmingCharacters(in: .whitespacesAndNewlines),
              !urlString.isEmpty,
              let url = URL(string: urlString),
              let scheme = url.scheme?.lowercased(),
              ["http", "https"].contains(scheme) else {
            return nil
        }

        return url
    }

    private func viewDocument(_ document: StudentDocument) {
        guard let url = remoteURL(for: document) else {
            showDocumentError("This document does not have a valid file URL.")
            return
        }

        let cacheDirectory = FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        )[0].appendingPathComponent(
            "StudentProfileDocuments",
            isDirectory: true
        )

        downloadDocument(
            document,
            from: url,
            into: cacheDirectory
        ) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let localURL):
                self.previewFileURL = localURL

                let previewController = QLPreviewController()
                previewController.dataSource = self
                self.present(previewController, animated: true)

            case .failure(let error):
                self.showDocumentError(error.localizedDescription)
            }
        }
    }

    private func downloadDocument(_ document: StudentDocument) {
        guard let url = remoteURL(for: document) else {
            showDocumentError("This document does not have a valid file URL.")
            return
        }

        let documentsDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0].appendingPathComponent(
            "StudentDocuments",
            isDirectory: true
        )

        downloadDocument(
            document,
            from: url,
            into: documentsDirectory
        ) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let localURL):
                let activityController = UIActivityViewController(
                    activityItems: [localURL],
                    applicationActivities: nil
                )

                if let popover = activityController.popoverPresentationController {
                    popover.sourceView = self.view
                    popover.sourceRect = CGRect(
                        x: self.view.bounds.midX,
                        y: self.view.bounds.midY,
                        width: 0,
                        height: 0
                    )
                    popover.permittedArrowDirections = []
                }

                self.present(activityController, animated: true)

            case .failure(let error):
                self.showDocumentError(error.localizedDescription)
            }
        }
    }

    private func downloadDocument(
        _ document: StudentDocument,
        from remoteURL: URL,
        into directoryURL: URL,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        do {
            try FileManager.default.createDirectory(
                at: directoryURL,
                withIntermediateDirectories: true
            )
        } catch {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            return
        }

        URLSession.shared.downloadTask(with: remoteURL) {
            temporaryURL,
            response,
            error in

            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse,
               !(200..<300).contains(httpResponse.statusCode) {
                let error = NSError(
                    domain: "StudentDocumentDownload",
                    code: httpResponse.statusCode,
                    userInfo: [
                        NSLocalizedDescriptionKey:
                            "The document download failed with status \(httpResponse.statusCode)."
                    ]
                )

                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let temporaryURL = temporaryURL else {
                let error = NSError(
                    domain: "StudentDocumentDownload",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "The downloaded document could not be found."
                    ]
                )

                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            let destinationURL = Self.destinationURL(
                for: document,
                remoteURL: remoteURL,
                response: response,
                directoryURL: directoryURL
            )

            do {
                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    try FileManager.default.removeItem(at: destinationURL)
                }

                try FileManager.default.moveItem(
                    at: temporaryURL,
                    to: destinationURL
                )

                DispatchQueue.main.async {
                    completion(.success(destinationURL))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    private static func destinationURL(
        for document: StudentDocument,
        remoteURL: URL,
        response: URLResponse?,
        directoryURL: URL
    ) -> URL {
        let suggestedExtension = response?.suggestedFilename
            .map { URL(fileURLWithPath: $0).pathExtension } ?? ""

        let fileExtension = remoteURL.pathExtension.isEmpty
            ? suggestedExtension
            : remoteURL.pathExtension

        let title = document.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let documentType = document.documentType.trimmingCharacters(in: .whitespacesAndNewlines)

        let baseName: String
        if !title.isEmpty {
            baseName = title
        } else if !documentType.isEmpty {
            baseName = documentType
        } else {
            baseName = "StudentDocument"
        }

        let identifier = document.id.isEmpty
            ? UUID().uuidString
            : document.id

        let safeBaseName = safeFileNameComponent(baseName)
        let safeIdentifier = safeFileNameComponent(identifier)
        let extensionSuffix = fileExtension.isEmpty ? "" : ".\(fileExtension)"

        let fileName = "\(safeBaseName)_\(safeIdentifier)\(extensionSuffix)"

        return directoryURL.appendingPathComponent(
            fileName,
            isDirectory: false
        )
    }

    private static func safeFileNameComponent(_ value: String) -> String {
        let invalidCharacters = CharacterSet(
            charactersIn: "/\\?%*|\"<>:"
        )

        let safeValue = value
            .components(separatedBy: invalidCharacters)
            .joined(separator: "_")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return safeValue.isEmpty ? "StudentDocument" : safeValue
    }

    private func showDocumentError(_ message: String) {
        let alert = UIAlertController(
            title: "Document",
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(title: "OK", style: .default)
        )

        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension StudentprofileVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        // Row 0 is the student details cell. Each document gets its own reusable row.
        return 1 + (profileData?.documents?.count ?? 0)
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        if indexPath.row == 0 {
            return 1700
        } else {
            return 60
        }
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: cellIdentifier,
                for: indexPath
            ) as! StudentdetailsTableViewCell

            if let data = profileData {
                cell.configure(with: data)
            } else {
                cell.clearAllFields()
            }

            return cell
        }

        let cell = tableView.dequeueReusableCell(
            withIdentifier: documentCellIdentifier,
            for: indexPath
        ) as! DocumentsTableViewCell2

        let documents = profileData?.documents ?? []
        let documentIndex = indexPath.row - 1

        guard documents.indices.contains(documentIndex) else {
            return cell
        }

        let document = documents[documentIndex]
        cell.configure(with: document)

        cell.onViewDocumentTapped = { [weak self] in
            self?.viewDocument(document)
        }

        cell.onDownloadDocumentTapped = { [weak self] in
            self?.downloadDocument(document)
        }

        return cell
    }

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

// MARK: - Quick Look

extension StudentprofileVC: QLPreviewControllerDataSource {

    func numberOfPreviewItems(
        in controller: QLPreviewController
    ) -> Int {
        previewFileURL == nil ? 0 : 1
    }

    func previewController(
        _ controller: QLPreviewController,
        previewItemAt index: Int
    ) -> QLPreviewItem {
        return previewFileURL! as NSURL
    }
}
