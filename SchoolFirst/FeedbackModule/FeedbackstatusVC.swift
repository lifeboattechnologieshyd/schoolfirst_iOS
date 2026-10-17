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
        Tableview.estimatedRowHeight = 700

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

    // MARK: - ✅ Dynamic row height (subject + message + view1/view2 + timeline)
    private func textHeight(_ text: String, font: UIFont, width: CGFloat) -> CGFloat {
        guard !text.isEmpty else { return 0 }
        let rect = (text as NSString).boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil
        )
        return ceil(rect.height)
    }

    private func calculatedRowHeight(for feedback: Feedback, tableWidth: CGFloat) -> CGFloat {
        let width = max(tableWidth - 72, UIScreen.main.bounds.width - 72)

        // Subject (dark card)
        let subjectH = textHeight(
            feedback.subject,
            font: UIFont.systemFont(ofSize: 22, weight: .bold),
            width: width
        )

        // Message (inside view1)
        let messageH = textHeight(
            feedback.message,
            font: UIFont.systemFont(ofSize: 15, weight: .regular),
            width: width
        )

        // view1 grows with message (chrome ~70 + message + pad)
        let view1H = max(70 + messageH + 24, 120)

        // view2 — if used as extra label/container near subject
        let view2H: CGFloat = 24

        // Timeline: submit + responses + final status
        let timelineCount = 1 + feedback.responses.count + 1
        let timelineH = CGFloat(timelineCount) * 58.0 + 50.0

        // Fixed chrome:
        // dark card top (status/id) + padding  ~ 90
        // gaps                                  ~ 36
        // yellow banner                         ~ 72
        // bottom pad                            ~ 28
        let fixedChrome: CGFloat = 90 + 36 + 72 + 28

        let total = fixedChrome + subjectH + view1H + view2H + timelineH
        return max(total, 560)
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

    // ✅ Grows with view1, view2, subject, message
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let feedback = feedback else { return 700 }
        let w = tableView.bounds.width > 0 ? tableView.bounds.width : UIScreen.main.bounds.width
        return calculatedRowHeight(for: feedback, tableWidth: w)
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 700
    }
}
