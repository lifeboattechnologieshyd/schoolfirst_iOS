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

    // MARK: - Category Options (now loaded dynamically from API)
    private var feedbackCategories: [FeedbackCategoryOption] = []
    private var selectedCategory: FeedbackCategoryOption?
    private var isLoadingCategories: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupBackButton()

        // Fetch categories dynamically on load
        fetchFeedbackCategories()
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

    // MARK: - API Call: Fetch Feedback Categories
    private func fetchFeedbackCategories() {

        let schoolId = UserManager.shared.resolvedSchoolID

        guard !schoolId.isEmpty else {
            print("❌ Fetch Categories — schoolId is empty, skipping request")
            return
        }

        isLoadingCategories = true
        print("📡 Fetch Feedback Categories — schoolId: \(schoolId)")

        NetworkManager.shared.request(
            urlString: API.FEEDBACK_CATEGORIES,
            method: .GET,
            requiresAuth: true,
            parameters: nil,
            headers: ["X-School-Id": schoolId]
        ) { [weak self] (result: Result<APIResponse<[FeedbackCategoryItem]>, NetworkError>) in

            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoadingCategories = false

                switch result {
                case .success(let response):
                    print("✅ Categories Fetched:", response.description)

                    guard let items = response.data, !items.isEmpty else {
                        print("⚠️ No categories returned from API")
                        self.feedbackCategories = []
                        self.Tableview.reloadData()
                        return
                    }

                    // Map API items → dropdown options (only active ones)
                    self.feedbackCategories = items
                        .filter { $0.is_active }
                        .map { FeedbackCategoryOption(id: $0.id, name: $0.name) }

                    print("📦 Loaded \(self.feedbackCategories.count) active categories")
                    
                    // ✅ Reload table so the cell builds the dropdown menu with the fetched data
                    self.Tableview.reloadData()

                case .failure(let error):
                    print("❌ Fetch Categories Failed:", error)
                    self.feedbackCategories = []
                    self.Tableview.reloadData()
                }
            }
        }
    }

    // MARK: - Fallback Dropdown (ActionSheet) for older iOS (< 14.0)
    private func showCategoryPicker(sourceView: UIView) {
        let alert = UIAlertController(title: "Select Category", message: nil, preferredStyle: .actionSheet)

        for category in feedbackCategories {
            alert.addAction(UIAlertAction(title: category.name, style: .default, handler: { [weak self] _ in
                guard let self = self else { return }
                self.selectedCategory = category
                self.Tableview.reloadData()
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

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

    // MARK: - API Call: Submit New Feedback
    private func submitFeedback(categoryId: String, subject: String, message: String) {

        let schoolId = UserManager.shared.resolvedSchoolID
        let studentId = UserManager.shared.resolvedStudentID

        guard !schoolId.isEmpty else { return }
        guard !studentId.isEmpty else { return }

        let parameters: [String: Any] = [
            "student_id": studentId,
            "category_id": categoryId,
            "subject": subject,
            "message": message
        ]

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
                    guard let data = response.data else {
                        AlertManager.shared.showAlert(title: "Success", message: response.description)
                        return
                    }
                    self.navigateToSuccessScreen(with: data)

                case .failure:
                    AlertManager.shared.showAlert(title: "Error", message: "Failed to submit feedback. Please try again.")
                }
            }
        }
    }

    // MARK: - Navigate to Submission Success Screen
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

        // ✅ 1. Attach native floating menu to the button (iOS 14+)
        let menuOptions = feedbackCategories.map { (id: $0.id, name: $0.name) }
        
        cell.setupMenu(options: menuOptions, selectedId: selectedCategory?.id) { [weak self] id, name in
            guard let self = self else { return }
            
            // User selected an option from floating menu
            if let chosenCategory = self.feedbackCategories.first(where: { $0.id == id }) {
                self.selectedCategory = chosenCategory
                // Reload table to update label and checkmark in menu
                self.Tableview.reloadData()
            }
        }

        // ✅ 2. Handle taps BEFORE data is loaded, or fallback for iOS 13
        // Note: If UIMenu is active, it intercepts the tap so this won't fire (which is perfect!)
        cell.onCategoryDropdownTapped = { [weak self, weak cell] in
            guard let self = self, let cell = cell else { return }

            if self.isLoadingCategories {
                AlertManager.shared.showAlert(title: "Please Wait", message: "Loading categories...")
            } else if self.feedbackCategories.isEmpty {
                self.fetchFeedbackCategories()
                AlertManager.shared.showAlert(title: "No Categories", message: "Categories are not available right now. Please try again.")
            } else {
                // Fallback for iOS 13 (since it doesn't support UIMenu attached natively)
                if #unavailable(iOS 14.0) {
                    self.showCategoryPicker(sourceView: cell.catogerydropdownbutton)
                }
            }
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
