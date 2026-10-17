//
//  FeedbackoverviewVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 11/10/26.
//

import UIKit

class FeedbackoverviewVC: UIViewController {

    @IBOutlet weak var Tableview: UITableView!
    @IBOutlet weak var Notificationbutton: UIButton!
    @IBOutlet weak var Backbutton: UIButton!

    // MARK: - API Data
    private var feedbackList: [Feedback] = []
    private var filteredFeedbackList: [Feedback] = []
    
    // MARK: - Current Filter
    private var currentFilter: FeedbackoverviewVCTBLVWCell.FeedbackFilter = .all

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        setupBackButton()

        Tableview.separatorStyle = .none
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getFeedbackList()
    }

    private func setupTableView() {
        Tableview.delegate = self
        Tableview.dataSource = self
        Tableview.showsVerticalScrollIndicator = false
        Tableview.allowsSelection = true
        
        // Setup initial estimated height
        Tableview.estimatedRowHeight = 120

        Tableview.register(
            UINib(nibName: "FeedbackoverviewVCTBLVWCell", bundle: nil),
            forCellReuseIdentifier: "FeedbackoverviewVCTBLVWCell"
        )

        Tableview.register(
            UINib(nibName: "FeedbackoverviewVCTBLVWCell2", bundle: nil),
            forCellReuseIdentifier: "FeedbackoverviewVCTBLVWCell2"
        )
    }

    private func setupBackButton() {
        Backbutton.addTarget(self, action: #selector(backButtonTapped(_:)), for: .touchUpInside)
    }

    // MARK: - API Call
    private func getFeedbackList() {
        let schoolId = UserManager.shared.resolvedSchoolID
        let studentId = UserManager.shared.resolvedStudentID

        guard !schoolId.isEmpty, !studentId.isEmpty else { return }

        NetworkManager.shared.request(
            urlString: API.FEEDBACK_LIST,
            method: .GET,
            requiresAuth: true,
            parameters: ["student_id": studentId],
            headers: ["X-School-Id": schoolId]
        ) { [weak self] (result: Result<APIResponse<[Feedback]>, NetworkError>) in

            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    self.feedbackList = response.data ?? []
                    self.applyCurrentFilter()
                case .failure(_):
                    self.feedbackList = []
                    self.filteredFeedbackList = []
                    self.Tableview.reloadData()
                }
            }
        }
    }

    // MARK: - Apply Filter
    private func applyCurrentFilter() {
        switch currentFilter {
        case .all:
            filteredFeedbackList = feedbackList
        case .pending:
            filteredFeedbackList = feedbackList.filter {
                let s = $0.status.uppercased()
                return s == "SUBMITTED" || s == "PENDING"
            }
        case .inReview:
            filteredFeedbackList = feedbackList.filter {
                let s = $0.status.uppercased()
                return s == "IN_REVIEW" || s == "IN REVIEW"
            }
        case .resolved:
            filteredFeedbackList = feedbackList.filter { $0.status.uppercased() == "RESOLVED" }
        }
        Tableview.reloadData()
    }

    @IBAction func backButtonTapped(_ sender: UIButton) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }

    private func feedbackCounts() -> (pending: Int, inReview: Int, resolved: Int) {
        let pendingCount = feedbackList.filter { $0.status.uppercased() == "SUBMITTED" || $0.status.uppercased() == "PENDING" }.count
        let inReviewCount = feedbackList.filter { $0.status.uppercased() == "IN_REVIEW" || $0.status.uppercased() == "IN REVIEW" }.count
        let resolvedCount = feedbackList.filter { $0.status.uppercased() == "RESOLVED" }.count
        return (pendingCount, inReviewCount, resolvedCount)
    }

    private func navigateForStatus(_ statusText: String, feedback: Feedback) {
        let storyboard = self.storyboard ?? UIStoryboard(name: "Main", bundle: nil)
        let normalized = statusText.trimmingCharacters(in: .whitespacesAndNewlines).uppercased().replacingOccurrences(of: "_", with: " ")

        switch normalized {
        case "SUBMITTED", "PENDING":
            if let vc = storyboard.instantiateViewController(withIdentifier: "FeedbackstatusVC") as? FeedbackstatusVC {
                vc.feedback = feedback
                navigationController?.pushViewController(vc, animated: true)
            }
        case "IN REVIEW":
            if let vc = storyboard.instantiateViewController(withIdentifier: "FeedbackinreviewVC") as? FeedbackinreviewVC {
                vc.feedback = feedback
                navigationController?.pushViewController(vc, animated: true)
            }
        case "RESOLVED":
            if let vc = storyboard.instantiateViewController(withIdentifier: "FeedbackResolvedVC") as? FeedbackResolvedVC {
                vc.feedback = feedback
                navigationController?.pushViewController(vc, animated: true)
            }
        default: break
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension FeedbackoverviewVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredFeedbackList.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FeedbackoverviewVCTBLVWCell", for: indexPath) as! FeedbackoverviewVCTBLVWCell
            let counts = feedbackCounts()

            cell.updateCounts(pending: counts.pending, inReview: counts.inReview, resolved: counts.resolved)
            cell.setSelectedFilter(currentFilter)

            cell.onCreateNewFeedbackTapped = { [weak self] in
                guard let self = self else { return }
                let storyboard = self.storyboard ?? UIStoryboard(name: "Main", bundle: nil)
                if let submitVC = storyboard.instantiateViewController(withIdentifier: "SubmitnewfeedbackVC") as? SubmitnewfeedbackVC {
                    self.navigationController?.pushViewController(submitVC, animated: true)
                }
            }
            
            cell.onFilterSelected = { [weak self] filter in
                guard let self = self else { return }
                self.currentFilter = filter
                self.applyCurrentFilter()
            }
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedbackoverviewVCTBLVWCell2", for: indexPath) as! FeedbackoverviewVCTBLVWCell2
        let feedback = filteredFeedbackList[indexPath.row - 1]
        
        cell.configure(with: feedback)
        cell.onStatusTapped = { [weak self] statusText in
            self?.navigateForStatus(statusText, feedback: feedback)
        }
        return cell
    }

    // ✅ FULLY FIXED: Using precise calculations based on device width to avoid empty space and truncation.
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 250 // Static height for the top header cell
        }
        
        let feedback = filteredFeedbackList[indexPath.row - 1]
        
        // 1. Get the actual width of the device screen to calculate exact wrap points.
        // Assuming ~16 for outer margins + ~16 inner padding = 64pt deduction from total width.
        let availableWidth = UIScreen.main.bounds.width - 64
        
        // 2. Measure exactly how tall the Subject text is.
        let subjectHeight = feedback.subject.boundingRect(
            with: CGSize(width: availableWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .semibold)],
            context: nil
        ).height
        
        // 3. Measure exactly how tall the Message text is.
        let messageHeight = feedback.message.boundingRect(
            with: CGSize(width: availableWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .regular)],
            context: nil
        ).height
        
        // 4. Calculate final dynamically perfect height.
        // `75` accounts for standard padding (Top, bottom, category string layout gaps).
        let calculatedHeight = ceil(subjectHeight) + ceil(messageHeight) + 75
        
        // Ensure it doesn't shrink below the design's minimum (108)
        return max(calculatedHeight, 108)
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 { return 250 }
        return 120
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.row > 0 else { return }
        let feedback = filteredFeedbackList[indexPath.row - 1]
        navigateForStatus(feedback.status, feedback: feedback)
    }
}
