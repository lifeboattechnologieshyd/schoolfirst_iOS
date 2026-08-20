//
//  HomeworkDetailsVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 09/06/26.
//

import UIKit

class HomeworkDetailsVC: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var NotificationButton: UIButton!
    @IBOutlet weak var BackButton: UIButton!
    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var TopView: UIView!

    // MARK: - Received Homework

    /// Passed from HomeworkVC.
    var studentHomework: StudentHomework?

    // MARK: - API Data

    private var homeworkDetails: StudentHomework?
    private var isLoading = false
    private var isSubmitting = false
    private var loadedStudentId = ""

    // MARK: - Optional Attachments

    /*
     Attachments are optional.

     Leave this array empty when the student is submitting
     without any attachment.

     After implementing file upload, add the uploaded file
     information to this array before tapping Submit.
     */
    var submissionAttachments: [HomeworkSubmissionAttachment] = []

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTopViewShadow()
        setupTableView()
        setupKeyboardDismissal()

        // Display the homework passed from HomeworkVC immediately.
        homeworkDetails = studentHomework
        TableView.reloadData()

        UserManager.shared.debugPrint()

        // Fetch the latest homework information.
        fetchHomeworkDetails()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let currentStudentId =
            UserManager.shared.resolvedStudentID

        guard !currentStudentId.isEmpty else {
            return
        }

        // Reload when selected student changes.
        if currentStudentId != loadedStudentId,
           !isLoading {

            fetchHomeworkDetails()
        }
    }

    // MARK: - Actions

    @IBAction func BackButtonTapped(_ sender: UIButton) {

        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    @IBAction func NotificationButtonTapped(_ sender: UIButton) {
        navigateToNotificationVC()
    }

    // MARK: - Fetch Homework Details API

    private func fetchHomeworkDetails() {

        let studentId =
            UserManager.shared.resolvedStudentID

        let schoolId =
            UserManager.shared.resolvedSchoolID

        guard !studentId.isEmpty,
              !schoolId.isEmpty else {

            isLoading = false
            TableView.refreshControl?.endRefreshing()

            print(
                "❌ HomeworkDetailsVC: Student ID or School ID is empty"
            )

            // Continue displaying the model passed from HomeworkVC.
            if homeworkDetails == nil {

                showTableMessage(
                    "Student or school information is unavailable."
                )
            }

            return
        }

        guard !isLoading else {
            return
        }

        isLoading = true

        if homeworkDetails == nil {

            showTableMessage(
                "Loading homework details..."
            )
        }

        NetworkManager.shared.request(
            urlString: API.STUDENT_HOMEWORK,
            method: .GET,
            requiresAuth: true,
            parameters: [
                "student_id": studentId
            ],
            headers: [
                "X-School-Id": schoolId
            ]
        ) { [weak self]
            (result: Result<
                APIResponse<StudentHomeworkData>,
                NetworkError
            >) in

            guard let self = self else {
                return
            }

            DispatchQueue.main.async {

                self.isLoading = false

                self.TableView.refreshControl?
                    .endRefreshing()

                switch result {

                case .success(let response):

                    guard response.success,
                          let homeworkData = response.data else {

                        print(
                            "❌ Homework details API returned no data"
                        )

                        // Preserve the model passed from HomeworkVC.
                        if self.homeworkDetails == nil {

                            self.showTableMessage(
                                "Homework details are unavailable."
                            )
                        }

                        self.TableView.reloadData()
                        return
                    }

                    self.loadedStudentId = studentId

                    // Find the selected homework using the homework ID.
                    if let selectedHomeworkId =
                        self.studentHomework?.id {

                        let matchingHomework =
                            homeworkData.homeworks.first {
                                $0.id == selectedHomeworkId
                            }

                        if let matchingHomework =
                            matchingHomework {

                            self.homeworkDetails =
                                matchingHomework

                            self.studentHomework =
                                matchingHomework

                            self.hideTableMessage()

                            print(
                                "✅ Homework details updated from API"
                            )

                            print(
                                "✅ Homework ID: \(matchingHomework.id)"
                            )

                            print(
                                "✅ Homework title: \(matchingHomework.title)"
                            )

                        } else {

                            print(
                                "⚠️ Selected homework was not found in the latest API response"
                            )

                            if self.homeworkDetails != nil {

                                self.hideTableMessage()

                            } else {

                                self.showTableMessage(
                                    "Homework details are unavailable."
                                )
                            }
                        }

                    } else if let firstHomework =
                                homeworkData.homeworks.first {

                        // Fallback when the screen is opened without a model.
                        self.homeworkDetails =
                            firstHomework

                        self.studentHomework =
                            firstHomework

                        self.hideTableMessage()

                        print(
                            "⚠️ No homework ID provided. Displaying first homework."
                        )

                    } else {

                        self.homeworkDetails = nil

                        self.showTableMessage(
                            "No homework available."
                        )

                        print(
                            "ℹ️ Homework array is empty"
                        )
                    }

                case .failure(let error):

                    print(
                        "❌ Homework details API failed: \(error)"
                    )

                    // Continue showing the passed model on refresh failure.
                    if self.homeworkDetails != nil {

                        self.hideTableMessage()

                    } else {

                        self.showTableMessage(
                            "Unable to load homework details.\nPlease try again."
                        )
                    }
                }

                self.TableView.reloadData()
            }
        }
    }

    // MARK: - Submit Homework POST API

    private func submitHomework(
        remarks: String?,
        attachments: [HomeworkSubmissionAttachment]?,
        from cell: HomeworkDetailsTableViewCell
    ) {

        guard !isSubmitting else {
            return
        }

        guard let homework =
                homeworkDetails ?? studentHomework else {

            AlertManager.shared.showAlert(
                title: "Error",
                message: "Homework information is unavailable."
            )

            return
        }

        let studentId =
            UserManager.shared.resolvedStudentID

        let schoolId =
            UserManager.shared.resolvedSchoolID

        guard !studentId.isEmpty else {

            AlertManager.shared.showAlert(
                title: "Error",
                message: "Student information is unavailable."
            )

            return
        }

        guard !schoolId.isEmpty else {

            AlertManager.shared.showAlert(
                title: "Error",
                message: "School information is unavailable."
            )

            return
        }

        let trimmedRemarks =
            remarks?
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                ) ?? ""

        // Student ID is required.
        var parameters: [String: Any] = [
            "student_id": studentId
        ]

        /*
         Remarks are optional.

         When the text view is empty, the remarks key is
         not added to the JSON payload.
         */
        if !trimmedRemarks.isEmpty {

            parameters["remarks"] =
                trimmedRemarks
        }

        /*
         Attachments are optional.

         When the attachment array is nil or empty, the
         attachments key is not added to the payload.
         */
        if let attachments = attachments,
           !attachments.isEmpty {

            parameters["attachments"] =
                attachments.map { attachment in

                    return [
                        "file_name": attachment.fileName,
                        "file_url": attachment.fileURL
                    ]
                }
        }

        isSubmitting = true

        view.endEditing(true)

        cell.setSubmitting(
            true
        )

        print("📤 Submitting homework")
        print("📘 Homework ID: \(homework.id)")
        print("👤 Student ID: \(studentId)")
        print("🏫 School ID: \(schoolId)")

        if trimmedRemarks.isEmpty {

            print("📝 Remarks: Not included")

        } else {

            print("📝 Remarks: \(trimmedRemarks)")
        }

        if let attachments = attachments,
           !attachments.isEmpty {

            print(
                "📎 Attachments count: \(attachments.count)"
            )

        } else {

            print(
                "📎 Attachments: Not included"
            )
        }

        print(
            "📦 Submission payload: \(parameters)"
        )

        NetworkManager.shared.request(
            urlString: API.HOMEWORK_SUBMISSION(
                homeworkID: homework.id
            ),
            method: .POST,
            requiresAuth: true,
            parameters: parameters,
            headers: [
                "X-School-Id": schoolId
            ]
        ) { [weak self, weak cell]
            (result: Result<
                APIResponse<HomeworkSubmissionResponseData>,
                NetworkError
            >) in

            guard let self = self else {
                return
            }

            DispatchQueue.main.async {

                self.isSubmitting = false

                cell?.setSubmitting(
                    false
                )

                switch result {

                case .success(let response):

                    guard response.success else {

                        let message =
                            response.description.isEmpty
                            ? "Unable to submit homework."
                            : response.description

                        AlertManager.shared.showAlert(
                            title: "Submission Failed",
                            message: message
                        )

                        return
                    }

                    if let submissionData =
                        response.data {

                        print(
                            "✅ Homework submitted successfully"
                        )

                        print(
                            "✅ Submission ID: \(submissionData.submissionId)"
                        )

                        print(
                            "✅ Submitted at: \(submissionData.submittedAt)"
                        )

                        print(
                            "✅ Status: \(submissionData.status)"
                        )

                    } else {

                        print(
                            "✅ Homework submitted successfully, but response data is empty"
                        )
                    }

                    self.navigateToMarkedCompletedVC()

                case .failure(let error):

                    print(
                        "❌ Homework submission failed: \(error)"
                    )

                    // NetworkManager already displays alerts for these errors.
                    switch error {

                    case .noData,
                         .noaccess,
                         .noInternet:

                        break

                    case .invalidURL,
                         .decodingError,
                         .serverError:

                        AlertManager.shared.showAlert(
                            title: "Submission Failed",
                            message: self.submissionErrorMessage(
                                for: error
                            )
                        )
                    }
                }
            }
        }
    }

    // MARK: - Submission Error Message

    private func submissionErrorMessage(
        for error: NetworkError
    ) -> String {

        switch error {

        case .invalidURL:

            return "The submission URL is invalid."

        case .noData:

            return "The server returned no data."

        case .noaccess:

            return "Your session has expired. Please log in again."

        case .noInternet:

            return "No internet connection."

        case .decodingError(let message):

            print(
                "❌ Submission decoding error: \(message)"
            )

            return "The server response could not be processed."

        case .serverError(let message):

            print(
                "❌ Submission server error: \(message)"
            )

            return "Unable to submit homework. Please try again."
        }
    }

    // MARK: - Navigate to MarkedcompletedVC

    // MARK: - Navigate to MarkedcompletedVC

    private func navigateToMarkedCompletedVC() {

        let storyboard = UIStoryboard(
            name: "Main",
            bundle: nil
        )

        guard let markedCompletedVC =
                storyboard.instantiateViewController(
                    withIdentifier: "MarkedcompletedVC"
                ) as? MarkedcompletedVC else {

            print(
                "❌ MarkedcompletedVC not found. Check Storyboard ID."
            )

            return
        }

        let selectedHomework =
            homeworkDetails ?? studentHomework

        // Pass the selected homework ID so MarkedcompletedVC
        // can find the correct homework from the latest API response.
        markedCompletedVC.homeworkID =
            selectedHomework?.id

        // Pass the existing model to display immediately while
        // MarkedcompletedVC refreshes from the API.
        markedCompletedVC.submittedHomework =
            selectedHomework

        markedCompletedVC.hidesBottomBarWhenPushed =
            true

        if let navigationController =
            navigationController {

            navigationController.pushViewController(
                markedCompletedVC,
                animated: true
            )

        } else {

            markedCompletedVC.modalPresentationStyle =
                .fullScreen

            present(
                markedCompletedVC,
                animated: true
            )
        }
    }
    // MARK: - Pull to Refresh

    @objc
    private func refreshHomeworkDetails() {

        loadedStudentId = ""
        fetchHomeworkDetails()
    }

    // MARK: - Keyboard

    private func setupKeyboardDismissal() {

        let tapGesture =
            UITapGestureRecognizer(
                target: self,
                action: #selector(dismissKeyboard)
            )

        tapGesture.cancelsTouchesInView =
            false

        view.addGestureRecognizer(
            tapGesture
        )
    }

    @objc
    private func dismissKeyboard() {

        view.endEditing(
            true
        )
    }

    // MARK: - Notification Navigation

    private func navigateToNotificationVC() {

        let storyboard =
            UIStoryboard(
                name: "Main",
                bundle: nil
            )

        guard let notificationVC =
                storyboard.instantiateViewController(
                    withIdentifier: "NotificationVC"
                ) as? NotificationVC else {

            print(
                "❌ NotificationVC not found"
            )

            return
        }

        notificationVC.hidesBottomBarWhenPushed =
            true

        if let navigationController =
            navigationController {

            navigationController.pushViewController(
                notificationVC,
                animated: true
            )

        } else {

            notificationVC.modalPresentationStyle =
                .fullScreen

            present(
                notificationVC,
                animated: true
            )
        }
    }

    // MARK: - Top View Setup

    private func setupTopViewShadow() {

        TopView.layer.shadowColor =
            UIColor.lightGray.cgColor

        TopView.layer.shadowOpacity =
            0.4

        TopView.layer.shadowOffset =
            CGSize(
                width: 0,
                height: 4
            )

        TopView.layer.shadowRadius =
            2

        TopView.layer.masksToBounds =
            false
    }

    // MARK: - Table Setup

    private func setupTableView() {

        TableView.delegate =
            self

        TableView.dataSource =
            self

        TableView.register(
            UINib(
                nibName: "HomeworkDetailsTableViewCell",
                bundle: nil
            ),
            forCellReuseIdentifier:
                "HomeworkDetailsTableViewCell"
        )

        TableView.separatorStyle =
            .none

        TableView.showsVerticalScrollIndicator =
            false

        TableView.keyboardDismissMode =
            .interactive

        let refreshControl =
            UIRefreshControl()

        refreshControl.addTarget(
            self,
            action: #selector(refreshHomeworkDetails),
            for: .valueChanged
        )

        TableView.refreshControl =
            refreshControl
    }

    // MARK: - Table Message

    private func showTableMessage(
        _ message: String
    ) {

        let messageLabel =
            UILabel(
                frame: TableView.bounds
            )

        messageLabel.text =
            message

        messageLabel.textAlignment =
            .center

        messageLabel.numberOfLines =
            0

        messageLabel.textColor =
            .secondaryLabel

        messageLabel.font =
            UIFont.systemFont(
                ofSize: 15,
                weight: .medium
            )

        TableView.backgroundView =
            messageLabel
    }

    private func hideTableMessage() {

        TableView.backgroundView =
            nil
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension HomeworkDetailsVC:
    UITableViewDelegate,
    UITableViewDataSource {

    func numberOfSections(
        in tableView: UITableView
    ) -> Int {

        return 1
    }

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {

        return homeworkDetails == nil
            ? 0
            : 1
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell =
            tableView.dequeueReusableCell(
                withIdentifier:
                    "HomeworkDetailsTableViewCell",
                for: indexPath
            ) as! HomeworkDetailsTableViewCell

        cell.selectionStyle =
            .none

        if let homework =
            homeworkDetails {

            cell.configure(
                with: homework
            )
        }

        cell.setSubmitting(
            isSubmitting
        )

        cell.onSubmitTapped = { [weak self, weak cell]
            remarks in

            guard let self = self,
                  let cell = cell else {
                return
            }

            /*
             Remarks may be empty.
             Attachments may also be empty.
             */
            self.submitHomework(
                remarks: remarks,
                attachments:
                    self.submissionAttachments.isEmpty
                    ? nil
                    : self.submissionAttachments,
                from: cell
            )
        }

        return cell
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {

        return 1200
    }
}
