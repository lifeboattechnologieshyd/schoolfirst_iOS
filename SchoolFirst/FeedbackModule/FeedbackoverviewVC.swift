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
    private var feedbackList: [Feedback] = []        // Full list from API
    private var filteredFeedbackList: [Feedback] = [] // Filtered display list
    
    // MARK: - Current Filter
    private var currentFilter: FeedbackoverviewVCTBLVWCell.FeedbackFilter = .all

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        setupBackButton()

        Tableview.separatorStyle = .none
        getFeedbackList()
    }

    private func setupTableView() {
        Tableview.delegate = self
        Tableview.dataSource = self
        Tableview.showsVerticalScrollIndicator = false
        Tableview.allowsSelection = true

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
        Backbutton.addTarget(
            self,
            action: #selector(backButtonTapped(_:)),
            for: .touchUpInside
        )
    }

    // MARK: - API Call
    private func getFeedbackList() {
        let schoolId = UserManager.shared.resolvedSchoolID
        let studentId = UserManager.shared.resolvedStudentID

        guard !schoolId.isEmpty else {
            print("❌ Feedback API — schoolId is empty, skipping request")
            return
        }
        guard !studentId.isEmpty else {
            print("❌ Feedback API — studentId is empty, skipping request")
            return
        }

        print("📡 Feedback API — schoolId: \(schoolId), studentId: \(studentId)")

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
                    print("✅ Feedback API Success: \(response.success)")
                    self.feedbackList = response.data ?? []
                    self.applyCurrentFilter()

                case .failure(let error):
                    print("❌ Feedback API Failed: \(error)")
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
            filteredFeedbackList = feedbackList.filter {
                $0.status.uppercased() == "RESOLVED"
            }
        }
        
        print("🔍 Filter applied: \(currentFilter.rawValue) — Count: \(filteredFeedbackList.count)")
        Tableview.reloadData()
    }

    // MARK: - Back Navigation Action
    @IBAction func backButtonTapped(_ sender: UIButton) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }

    // MARK: - Feedback Count Calculation (always based on FULL list)
    private func feedbackCounts() -> (pending: Int, inReview: Int, resolved: Int) {
        let pendingCount = feedbackList.filter {
            $0.status.uppercased() == "SUBMITTED" ||
            $0.status.uppercased() == "PENDING"
        }.count

        let inReviewCount = feedbackList.filter {
            $0.status.uppercased() == "IN_REVIEW" ||
            $0.status.uppercased() == "IN REVIEW"
        }.count

        let resolvedCount = feedbackList.filter {
            $0.status.uppercased() == "RESOLVED"
        }.count

        return (pendingCount, inReviewCount, resolvedCount)
    }

    // MARK: - Navigate Based on Status
    private func navigateForStatus(_ statusText: String, feedback: Feedback) {

        let storyboard = self.storyboard ?? UIStoryboard(name: "Main", bundle: nil)

        let normalized = statusText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()
            .replacingOccurrences(of: "_", with: " ")

        print("📍 navigateForStatus — raw status: \(statusText), normalized: \(normalized), feedbackId: \(feedback.id), subject: \(feedback.subject)")

        switch normalized {

        case "SUBMITTED", "PENDING":
            if let vc = storyboard.instantiateViewController(
                withIdentifier: "FeedbackstatusVC"
            ) as? FeedbackstatusVC {
                vc.feedback = feedback
                navigationController?.pushViewController(vc, animated: true)
            }

        case "IN REVIEW":
            if let vc = storyboard.instantiateViewController(
                withIdentifier: "FeedbackinreviewVC"
            ) as? FeedbackinreviewVC {
                vc.feedback = feedback
                navigationController?.pushViewController(vc, animated: true)
            }

        case "RESOLVED":
            if let vc = storyboard.instantiateViewController(
                withIdentifier: "FeedbackResolvedVC"
            ) as? FeedbackResolvedVC {
                vc.feedback = feedback
                navigationController?.pushViewController(vc, animated: true)
            }

        default:
            print("⚠️ Unknown status tapped: \(statusText)")
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension FeedbackoverviewVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Row 0 = Summary card
        // Remaining = filtered feedback list
        return filteredFeedbackList.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // MARK: Summary Cell
        if indexPath.row == 0 {

            let cell = tableView.dequeueReusableCell(
                withIdentifier: "FeedbackoverviewVCTBLVWCell",
                for: indexPath
            ) as! FeedbackoverviewVCTBLVWCell

            let counts = feedbackCounts()

            cell.updateCounts(
                pending: counts.pending,
                inReview: counts.inReview,
                resolved: counts.resolved
            )
            
            // Keep selected filter highlighted on cell reuse
            cell.setSelectedFilter(currentFilter)

            // Create New Feedback button
            cell.onCreateNewFeedbackTapped = { [weak self] in
                guard let self = self else { return }
                let storyboard = self.storyboard ?? UIStoryboard(name: "Main", bundle: nil)
                if let submitVC = storyboard.instantiateViewController(
                    withIdentifier: "SubmitnewfeedbackVC"
                ) as? SubmitnewfeedbackVC {
                    self.navigationController?.pushViewController(submitVC, animated: true)
                }
            }
            
            // ✅ Handle filter selection (Pending/InReview/Resolved cards + filter buttons)
            cell.onFilterSelected = { [weak self] filter in
                guard let self = self else { return }
                self.currentFilter = filter
                self.applyCurrentFilter()
            }

            return cell
        }

        // MARK: Feedback List Cell
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "FeedbackoverviewVCTBLVWCell2",
            for: indexPath
        ) as! FeedbackoverviewVCTBLVWCell2

        let feedback = filteredFeedbackList[indexPath.row - 1]
        cell.configure(with: feedback)

        cell.onStatusTapped = { [weak self] statusText in
            self?.navigateForStatus(statusText, feedback: feedback)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 250
        }
        return 108
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.row > 0 else { return }
        let feedback = filteredFeedbackList[indexPath.row - 1]
        print("👆 Row tapped — feedbackId: \(feedback.id), status: \(feedback.status)")
        navigateForStatus(feedback.status, feedback: feedback)
    }
}
