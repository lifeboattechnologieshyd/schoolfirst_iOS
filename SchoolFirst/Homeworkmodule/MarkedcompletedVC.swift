//
//  MarkedcompletedVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 18/08/26.
//

import UIKit

class MarkedcompletedVC: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var Backbutton: UIButton!
    @IBOutlet weak var Homeworktitlewithpdf: UILabel!
    @IBOutlet weak var Homeworktitle: UILabel!
    @IBOutlet weak var Subject: UILabel!
    @IBOutlet weak var Description: UILabel!
    @IBOutlet weak var TopView: UIView!

    // MARK: - Received Homework Data

    /// Selected homework ID passed from HomeworkDetailsVC.
    var homeworkID: String?

    /// Existing homework model passed from HomeworkDetailsVC.
    /// This is displayed immediately while the API is loading.
    var submittedHomework: StudentHomework?

    // MARK: - API State

    private var latestHomework: StudentHomework?
    private var isLoading = false
    private var loadedStudentId = ""

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTopViewShadow()

        // Immediately display the model received from
        // HomeworkDetailsVC, if it is available.
        if let homework = submittedHomework {

            latestHomework = homework
            configureUI(with: homework)
        } else {

            clearUI()
        }

        UserManager.shared.debugPrint()

        // Fetch the latest submission status and homework data.
        fetchSubmittedHomework()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let currentStudentId =
            UserManager.shared.resolvedStudentID

        guard !currentStudentId.isEmpty else {
            return
        }

        // Fetch again if the selected student changes.
        if currentStudentId != loadedStudentId,
           !isLoading {

            fetchSubmittedHomework()
        }
    }
    
    @IBAction func BackButtonTapped(_ sender: UIButton) {

        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    // MARK: - Fetch Homework API

    private func fetchSubmittedHomework() {

        let studentId =
            UserManager.shared.resolvedStudentID

        let schoolId =
            UserManager.shared.resolvedSchoolID

        guard !studentId.isEmpty else {

            isLoading = false

            print(
                "❌ MarkedcompletedVC: Student ID is empty"
            )

            if latestHomework == nil {

                showErrorAlert(
                    message: "Student information is unavailable."
                )
            }

            return
        }

        guard !schoolId.isEmpty else {

            isLoading = false

            print(
                "❌ MarkedcompletedVC: School ID is empty"
            )

            if latestHomework == nil {

                showErrorAlert(
                    message: "School information is unavailable."
                )
            }

            return
        }

        guard !isLoading else {
            return
        }

        isLoading = true

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

                switch result {

                case .success(let response):

                    guard response.success,
                          let homeworkData = response.data else {

                        print(
                            "❌ Marked completed homework API returned no data"
                        )

                        // Continue displaying the passed model if available.
                        if self.latestHomework == nil {

                            self.showErrorAlert(
                                message: response.description.isEmpty
                                    ? "Homework information is unavailable."
                                    : response.description
                            )
                        }

                        return
                    }

                    self.loadedStudentId =
                        studentId

                    let selectedHomeworkID =
                        self.homeworkID
                        ?? self.submittedHomework?.id

                    if let selectedHomeworkID =
                        selectedHomeworkID {

                        // Find the exact homework that was submitted.
                        if let matchingHomework =
                            homeworkData.homeworks.first(
                                where: {
                                    $0.id == selectedHomeworkID
                                }
                            ) {

                            self.latestHomework =
                                matchingHomework

                            self.submittedHomework =
                                matchingHomework

                            self.homeworkID =
                                matchingHomework.id

                            self.configureUI(
                                with: matchingHomework
                            )

                            print(
                                "✅ Submitted homework loaded successfully"
                            )

                            print(
                                "✅ Homework ID: \(matchingHomework.id)"
                            )

                            print(
                                "✅ Homework title: \(matchingHomework.title)"
                            )

                            print(
                                "✅ Submission status: \(matchingHomework.submission.status)"
                            )

                            print(
                                "✅ Submitted at: \(matchingHomework.submission.submittedAt ?? "N/A")"
                            )

                        } else {

                            print(
                                "⚠️ Submitted homework ID was not found in latest API response"
                            )

                            // Continue displaying the model passed from
                            // HomeworkDetailsVC when matching data is absent.
                            if let submittedHomework =
                                self.submittedHomework {

                                self.latestHomework =
                                    submittedHomework

                                self.configureUI(
                                    with: submittedHomework
                                )

                            } else {

                                self.clearUI()

                                self.showErrorAlert(
                                    message: "Submitted homework was not found."
                                )
                            }
                        }

                    } else if let firstHomework =
                                homeworkData.homeworks.first {

                        /*
                         Fallback when this screen was opened without
                         receiving a homework ID.
                         */
                        self.latestHomework =
                            firstHomework

                        self.submittedHomework =
                            firstHomework

                        self.homeworkID =
                            firstHomework.id

                        self.configureUI(
                            with: firstHomework
                        )

                        print(
                            "⚠️ No homework ID received. Displaying the first homework."
                        )

                    } else {

                        self.latestHomework = nil
                        self.clearUI()

                        self.showErrorAlert(
                            message: "No homework available."
                        )

                        print(
                            "ℹ️ Homework array is empty"
                        )
                    }

                case .failure(let error):

                    print(
                        "❌ Marked completed homework API failed: \(error)"
                    )

                    /*
                     Continue displaying the model passed from the
                     previous screen if the refresh request fails.
                     */
                    if let homework =
                        self.latestHomework
                        ?? self.submittedHomework {

                        self.configureUI(
                            with: homework
                        )

                    } else {

                        self.clearUI()

                        // NetworkManager already shows alerts for common
                        // network errors, so avoid presenting duplicates.
                        switch error {

                        case .invalidURL,
                             .decodingError:

                            self.showErrorAlert(
                                message: "Unable to load submitted homework."
                            )

                        case .noData,
                             .noaccess,
                             .noInternet,
                             .serverError:

                            break
                        }
                    }
                }
            }
        }
    }

    // MARK: - Configure Outlets

    private func configureUI(
        with homework: StudentHomework
    ) {

        Homeworktitle.text =
            homework.title

        Subject.text =
            homework.subject.name
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
                .capitalized

        Description.text =
            homework.description

        /*
         The homework/student API response does not provide
         an attachment file name. Therefore, use the homework
         title for this outlet.

         If this outlet must display a generated PDF name,
         replace the next line with:
         "\(homework.title).pdf"
         */
        Homeworktitlewithpdf.text =
            homework.title

        print(
            "✅ MarkedcompletedVC outlets configured"
        )

        print(
            "Title: \(homework.title)"
        )

        print(
            "Subject: \(homework.subject.name)"
        )

        print(
            "Description: \(homework.description)"
        )

        print(
            "Status: \(homework.submission.status)"
        )
    }

    // MARK: - Clear Outlets

    private func clearUI() {

        Homeworktitlewithpdf.text = nil
        Homeworktitle.text = nil
        Subject.text = nil
        Description.text = nil
    }

    // MARK: - Error Alert

    private func showErrorAlert(
        message: String
    ) {

        // Avoid presenting multiple alerts simultaneously.
        guard presentedViewController == nil else {
            return
        }

        let alert = UIAlertController(
            title: "Unable to Load",
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(
                title: "Retry",
                style: .default,
                handler: { [weak self] _ in

                    self?.loadedStudentId = ""
                    self?.fetchSubmittedHomework()
                }
            )
        )

        alert.addAction(
            UIAlertAction(
                title: "OK",
                style: .cancel
            )
        )

        present(
            alert,
            animated: true
        )
    }

    // MARK: - Top View Shadow

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
}
