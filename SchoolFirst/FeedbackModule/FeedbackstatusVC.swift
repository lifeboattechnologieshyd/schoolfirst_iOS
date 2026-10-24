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

    // MARK: - Passed-in Feedback Data
    var feedback: Feedback? {
        didSet {
            print("📦 FeedbackstatusVC — feedback set:", feedback?.subject ?? "nil")
            Tableview?.reloadData()
        }
    }

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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchFeedbackDetails()
    }

    // MARK: - Setup
    private func setupTableView() {
        Tableview.delegate = self
        Tableview.dataSource = self
        Tableview.showsVerticalScrollIndicator = false
        Tableview.separatorStyle = .none
        Tableview.rowHeight = UITableView.automaticDimension
        Tableview.estimatedRowHeight = 600

        Tableview.register(
            UINib(nibName: "FeedbacksummuryTBLVWCell", bundle: nil),
            forCellReuseIdentifier: "FeedbacksummuryTBLVWCell"
        )
    }

    private func setupBackButton() {
        Backbutton.addTarget(self, action: #selector(backButtonTapped(_:)), for: .touchUpInside)
    }

    // MARK: - API
    private func fetchFeedbackDetails() {

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
                        self.feedback = match
                    } else {
                        print("⚠️ FeedbackstatusVC — no feedback found for id:", targetId)
                        self.Tableview.reloadData()
                    }

                case .failure(let error):
                    print("❌ FeedbackstatusVC — fetch failed:", error)
                    self.Tableview.reloadData()
                }
            }
        }
    }

    // MARK: - Back
    @IBAction func backButtonTapped(_ sender: UIButton) {
        guard let navigationController = self.navigationController else {
            self.dismiss(animated: true, completion: nil)
            return
        }

        if let overviewVC = navigationController.viewControllers.first(where: { $0 is FeedbackoverviewVC }) {
            print("⬅️ Popping to FeedbackoverviewVC")
            navigationController.popToViewController(overviewVC, animated: true)
        } else {
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

        if let feedback = feedback {
            cell.configure(with: feedback)
        } else {
            print("❌ cellForRowAt — feedback is nil, cell will show static/default values")
        }

        return cell
    }

    // MARK: - Cell Height (Dynamic)
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 600
    }
}
