//
//  SubmitnewfeedbackVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 12/10/26.
//

import UIKit

class SubmitnewfeedbackVC: UIViewController {

    @IBOutlet weak var Tableview: UITableView!
    @IBOutlet weak var Backbutton: UIButton!

    // MARK: - Category Options (replace placeholder IDs with real backend category IDs if available)
    private let feedbackCategories: [FeedbackCategoryOption] = [
        FeedbackCategoryOption(id: "ac7e90aa-dc24-4902-8898-6ae67fb56edf", name: "Transport"),
        FeedbackCategoryOption(id: "b1e4b9f0-1234-4e56-8abc-9f1234567890", name: "Academic"),
        FeedbackCategoryOption(id: "c2f5c0a1-2345-4f67-9bcd-0f2345678901", name: "Behavior"),
        FeedbackCategoryOption(id: "d3g6d1b2-3456-4g78-0cde-1g3456789012", name: "Facilities"),
        FeedbackCategoryOption(id: "e4h7e2c3-4567-4h89-1def-2h4567890123", name: "Other")
    ]

    private var selectedCategory: FeedbackCategoryOption?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupBackButton()
    }

    private func setupTableView() {
        Tableview.delegate = self
        Tableview.dataSource = self
        Tableview.showsVerticalScrollIndicator = false

        Tableview.register(UINib(nibName: "FeedbacksubmitVCTBLVWCell1", bundle: nil), forCellReuseIdentifier: "FeedbacksubmitVCTBLVWCell1")
    }

    private func setupBackButton() {
        Backbutton.addTarget(self, action: #selector(backButtonTapped(_:)), for: .touchUpInside)
    }

    // MARK: - Back Navigation Action (Pop / Dismiss)
    @IBAction func backButtonTapped(_ sender: UIButton) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }

    // MARK: - Show Category Dropdown (ActionSheet)
    private func showCategoryPicker(sourceView: UIView) {

        let alert = UIAlertController(title: "Select Category", message: nil, preferredStyle: .actionSheet)

        for category in feedbackCategories {
            alert.addAction(UIAlertAction(title: category.name, style: .default, handler: { [weak self] _ in
                guard let self = self else { return }

                self.selectedCategory = category
                print("✅ Category selected:", category.name, "| id:", category.id)

                // ── Update label directly on the visible cell (avoids full reload,
                // which would wipe out subject/message text already typed) ──
                if let cell = self.Tableview.cellForRow(at: IndexPath(row: 0, section: 0)) as? FeedbacksubmitVCTBLVWCell1 {
                    cell.updateCategoryLabel(category.name)
                }
            }))
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        // iPad popover support (prevents crash on iPad)
        if let popover = alert.popoverPresentationController {
            popover.sourceView = sourceView
            popover.sourceRect = sourceView.bounds
        }

        present(alert, animated: true, completion: nil)
    }

    // MARK: - Validate + Submit
    private func handleSubmitTapped(cell: FeedbacksubmitVCTBLVWCell1) {

        let subject = cell.subjectText
        let message = cell.messageText

        guard !subject.isEmpty else {
            print("⚠️ Subject is empty")
            AlertManager.shared.showAlert(title: "Missing Subject", message: "Please enter feedback subject.")
            return
        }

        guard !message.isEmpty else {
            print("⚠️ Message is empty")
            AlertManager.shared.showAlert(title: "Missing Message", message: "Please enter feedback message.")
            return
        }

        guard let category = selectedCategory else {
            print("⚠️ Category not selected")
            AlertManager.shared.showAlert(title: "Missing Category", message: "Please select a category.")
            return
        }

        submitFeedback(categoryId: category.id, subject: subject, message: message)
    }

    // MARK: - ✅ API Call: Submit New Feedback
    private func submitFeedback(categoryId: String, subject: String, message: String) {

        // ── Resolve IDs from UserManager (UserDefaults-backed) ──
        let schoolId = UserManager.shared.resolvedSchoolID
        let studentId = UserManager.shared.resolvedStudentID

        guard !schoolId.isEmpty else {
            print("❌ Submit Feedback — schoolId is empty, skipping request")
            return
        }
        guard !studentId.isEmpty else {
            print("❌ Submit Feedback — studentId is empty, skipping request")
            return
        }

        let parameters: [String: Any] = [
            "student_id": studentId,
            "category_id": categoryId,
            "subject": subject,
            "message": message
        ]

        print("📡 Submit Feedback — schoolId: \(schoolId), studentId: \(studentId), categoryId: \(categoryId)")

        NetworkManager.shared.request(
            urlString: API.FEEDBACK_CREATE,
            method: .POST,
            requiresAuth: true,
            parameters: parameters,
            headers: ["X-School-Id": schoolId]
        ) { [weak self] (result: Result<APIResponse<FeedbackCreateData>, NetworkError>) in

            DispatchQueue.main.async {
                guard let self = self else { return }

                switch result {
                case .success(let response):
                    print("✅ Feedback Submitted:", response.description)

                    guard let data = response.data else {
                        print("⚠️ Feedback submitted but response.data is nil")
                        AlertManager.shared.showAlert(title: "Success", message: response.description)
                        return
                    }

                    print("📝 New Feedback ID:", data.id)
                    print("📌 Status:", data.status)

                    // ── ✅ Navigate to Success Screen with real API data ──
                    self.navigateToSuccessScreen(with: data)

                case .failure(let error):
                    print("❌ Feedback Submission Failed:", error)
                    AlertManager.shared.showAlert(
                        title: "Error",
                        message: "Failed to submit feedback. Please try again."
                    )
                }
            }
        }
    }

    // MARK: - ✅ Navigate to Submission Success Screen
    private func navigateToSuccessScreen(with data: FeedbackCreateData) {
        let successVC = FeedbackSubmissionsuccessfulVC()
        successVC.feedbackData = data
        navigationController?.pushViewController(successVC, animated: true)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension SubmitnewfeedbackVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "FeedbacksubmitVCTBLVWCell1",
            for: indexPath
        ) as! FeedbacksubmitVCTBLVWCell1

        // Show current category selection (or placeholder)
        cell.updateCategoryLabel(selectedCategory?.name ?? "Select Category")

        // Dropdown tap → show category picker
        cell.onCategoryDropdownTapped = { [weak self, weak cell] in
            guard let self = self, let cell = cell else { return }
            self.showCategoryPicker(sourceView: cell.catogerydropdownbutton)
        }

        // Submit tap → validate + call API
        cell.onSubmitTapped = { [weak self, weak cell] in
            guard let self = self, let cell = cell else { return }
            self.handleSubmitTapped(cell: cell)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 800
    }
}
