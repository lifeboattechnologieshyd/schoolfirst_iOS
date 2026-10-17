//
//  FeedbackstatusVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 12/10/26.
//

import UIKit

class FeedbackstatusVC: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var Tableview: UITableView!
    @IBOutlet weak var Backbutton: UIButton!

    // MARK: - ✅ Passed-in Feedback Data
    // didSet ensures table reloads automatically whenever feedback is assigned,
    // regardless of whether it's set before or after viewDidLoad.
    var feedback: Feedback? {
        didSet {
            print("📦 FeedbackstatusVC — feedback set:", feedback?.subject ?? "nil")
            Tableview?.reloadData()
        }
    }

    // MARK: - ✅ Feedback ID (used when navigating from Success screen)
    var feedbackId: String?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupBackButton()

        if feedback == nil && (feedbackId == nil || feedbackId?.isEmpty == true) {
            print("⚠️ FeedbackstatusVC — viewDidLoad: no feedback / feedbackId set yet.")
        } else {
            print("✅ FeedbackstatusVC — viewDidLoad: feedbackId →", feedbackId ?? feedback?.id ?? "nil")
        }

        Tableview.reloadData()
    }

    // MARK: - ✅ Call API on EVERY screen entry (first open + back navigation)
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchFeedbackDetails()
    }

    // MARK: - Setup Methods
    private func setupTableView() {
        Tableview.delegate = self
        Tableview.dataSource = self
        Tableview.showsVerticalScrollIndicator = false

        Tableview.register(UINib(nibName: "FeedbacksummuryTBLVWCell", bundle: nil), forCellReuseIdentifier: "FeedbacksummuryTBLVWCell")
    }

    private func setupBackButton() {
        Backbutton.addTarget(self, action: #selector(backButtonTapped(_:)), for: .touchUpInside)
    }

    // MARK: - ✅ API: Fetch feedback list and pick the matching feedback
    private func fetchFeedbackDetails() {

        // Prefer explicit feedbackId; fall back to already-assigned feedback.id
        let targetId = feedbackId ?? feedback?.id

        guard let targetId = targetId, !targetId.isEmpty else {
            print("⚠️ fetchFeedbackDetails — no feedbackId available, showing existing data (if any)")
            Tableview.reloadData()
            return
        }

        let schoolId = UserManager.shared.resolvedSchoolID
        let studentId = UserManager.shared.resolvedStudentID

        guard !schoolId.isEmpty else {
            print("❌ FeedbackstatusVC — schoolId is empty, skipping request")
            return
        }
        guard !studentId.isEmpty else {
            print("❌ FeedbackstatusVC — studentId is empty, skipping request")
            return
        }

        print("📡 FeedbackstatusVC — fetching list to find id:", targetId)

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
                    let list = response.data ?? []
                    if let match = list.first(where: { $0.id == targetId }) {
                        print("✅ FeedbackstatusVC — found feedback:", match.subject)
                        self.feedback = match   // didSet → reloads table
                    } else {
                        print("⚠️ FeedbackstatusVC — no feedback found for id:", targetId)
                        // Keep previously set feedback (if any) so UI is not wiped
                        self.Tableview.reloadData()
                    }

                case .failure(let error):
                    print("❌ FeedbackstatusVC — fetch failed:", error)
                    // Keep previously set feedback (if any)
                    self.Tableview.reloadData()
                }
            }
        }
    }

    // MARK: - ✅ Back Action → always land on FeedbackoverviewVC
    @IBAction func backButtonTapped(_ sender: UIButton) {
        guard let navigationController = self.navigationController else {
            self.dismiss(animated: true, completion: nil)
            return
        }

        // Pop directly to FeedbackoverviewVC if it exists in the stack
        // (covers: Overview → Status, and Overview → Submit → Success → Status)
        if let overviewVC = navigationController.viewControllers.first(where: { $0 is FeedbackoverviewVC }) {
            print("⬅️ Popping to FeedbackoverviewVC")
            navigationController.popToViewController(overviewVC, animated: true)
        } else {
            // Fallback: normal single pop
            print("⬅️ FeedbackoverviewVC not in stack — normal pop")
            navigationController.popViewController(animated: true)
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension FeedbackstatusVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "FeedbacksummuryTBLVWCell",
            for: indexPath
        ) as! FeedbacksummuryTBLVWCell

        // ── Populate cell with API feedback data ──
        if let feedback = feedback {
            cell.configure(with: feedback)
        } else {
            print("❌ cellForRowAt — feedback is nil, cell will show static/default values")
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 800
    }
}
