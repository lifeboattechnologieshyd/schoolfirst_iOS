//
//  leaverequestsVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 19/10/26.
//

import UIKit

private typealias LeaveListCompletion =
    (Result<APIResponse<LeaveListDataWrapper>, NetworkError>) -> Void

class leaverequestsVC: UIViewController {

    @IBOutlet weak var Newleaverequestbutton: UIButton!
    @IBOutlet weak var Academicyearandterm: UILabel!
    @IBOutlet weak var Tableview: UITableView!
    @IBOutlet weak var Backbutton: UIButton!

    // MARK: - API Keys
    private let schoolHeaderKey = "X-School-ID"

    private var leaveRequests: [LeaveListItem] = []
    private var totalRequestsCount = 0
    private var selectedFilter = "All"

    private var filteredRequests: [LeaveListItem] {
        guard selectedFilter != "All" else {
            return leaveRequests
        }
        return leaveRequests.filter {
            $0.status.caseInsensitiveCompare(selectedFilter) == .orderedSame
        }
    }

    private var pendingCount: Int {
        leaveRequests.filter { $0.status.caseInsensitiveCompare("PENDING") == .orderedSame }.count
    }

    private var approvedCount: Int {
        leaveRequests.filter { $0.status.caseInsensitiveCompare("APPROVED") == .orderedSame }.count
    }

    private var rejectedCount: Int {
        leaveRequests.filter { $0.status.caseInsensitiveCompare("REJECTED") == .orderedSame }.count
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        Backbutton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        Newleaverequestbutton.addTarget(self, action: #selector(didTapNewLeaveRequestButton), for: .touchUpInside)
        Academicyearandterm.text = "\(academicYearText()) · \(termText())"
        fetchLeaveRequests()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchLeaveRequests()
    }

    // MARK: - Back Button
    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - New Leave Request Button
    @objc private func didTapNewLeaveRequestButton() {
        navigateToLeaveApplyVC()
    }

    private func navigateToLeaveApplyVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let leaveApplyVC = storyboard.instantiateViewController(withIdentifier: "LeaveapplyVC") as? LeaveapplyVC {
            leaveApplyVC.hidesBottomBarWhenPushed = true
            if let nav = navigationController {
                nav.setNavigationBarHidden(true, animated: false)
                nav.pushViewController(leaveApplyVC, animated: true)
            } else {
                leaveApplyVC.modalPresentationStyle = .fullScreen
                present(leaveApplyVC, animated: true)
            }
        } else {
            // Fallback if storyboard ID is missing
            let leaveApplyVC = LeaveapplyVC()
            leaveApplyVC.hidesBottomBarWhenPushed = true
            if let nav = navigationController {
                nav.setNavigationBarHidden(true, animated: false)
                nav.pushViewController(leaveApplyVC, animated: true)
            } else {
                leaveApplyVC.modalPresentationStyle = .fullScreen
                present(leaveApplyVC, animated: true)
            }
        }
    }

    // MARK: - Table View
    private func setupTableView() {
        Tableview.delegate = self
        Tableview.dataSource = self
        Tableview.separatorStyle = .none
        Tableview.showsVerticalScrollIndicator = false
        Tableview.backgroundColor = UIColor(red: 0.95, green: 0.97, blue: 1.0, alpha: 1.0)
        Tableview.tableFooterView = UIView()

        let headerNib = UINib(nibName: "LeaverequestsTBLVCLL1", bundle: nil)
        Tableview.register(headerNib, forCellReuseIdentifier: "LeaverequestsTBLVCLL1")

        let requestNib = UINib(nibName: "LeaverequestsTBLVCLL2", bundle: nil)
        Tableview.register(requestNib, forCellReuseIdentifier: "LeaverequestsTBLVCLL2")
    }

    // MARK: - API
    private func fetchLeaveRequests() {
        let studentID = UserManager.shared.resolvedStudentID.trimmingCharacters(in: .whitespacesAndNewlines)
        let schoolID = UserManager.shared.resolvedSchoolID.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !studentID.isEmpty, !schoolID.isEmpty else { return }

        let completion: LeaveListCompletion = { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    if response.success {
                        self.leaveRequests = response.data?.data ?? []
                        self.totalRequestsCount = response.total ?? self.leaveRequests.count
                    } else {
                        self.leaveRequests = []
                        self.totalRequestsCount = 0
                    }
                    self.Tableview.reloadData()
                case .failure(_):
                    self.leaveRequests = []
                    self.totalRequestsCount = 0
                    self.Tableview.reloadData()
                }
            }
        }

        NetworkManager.shared.request(
            urlString: API.STUDENT_LEAVE_REQUESTS,
            method: .GET,
            requiresAuth: true,
            parameters: ["student_id": studentID, "student": studentID],
            headers: [schoolHeaderKey: schoolID],
            completion: completion
        )
    }

    // MARK: - Navigation to Reject Detail
    private func openRejectDetail(for item: LeaveListItem) {
        let vc: LeaveRejectVC
        if let storyboardVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LeaveRejectVC") as? LeaveRejectVC {
            vc = storyboardVC
        } else {
            vc = LeaveRejectVC()
        }
        
        vc.leaveItem = item
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Navigation to Approved Detail
    private func openApprovedDetail(for item: LeaveListItem) {
        let vc: ApprovedleavedetailsVC
        if let storyboardVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ApprovedleavedetailsVC") as? ApprovedleavedetailsVC {
            vc = storyboardVC
        } else {
            vc = ApprovedleavedetailsVC()
        }
        
        vc.leaveItem = item
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Academic / Term Helpers
    private func academicYearText() -> String {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: Date())
        let month = calendar.component(.month, from: Date())
        return month >= 6 ? "AY \(year)-\((year + 1) % 100)" : "AY \(year - 1)-\(year % 100)"
    }

    private func termText() -> String {
        let month = Calendar.current.component(.month, from: Date())
        switch month {
        case 6...10: return "Term 1"
        case 11, 12, 1, 2, 3: return "Term 2"
        default: return "Term 3"
        }
    }

    private func termWithRangeText() -> String {
        let month = Calendar.current.component(.month, from: Date())
        switch month {
        case 6...10: return "Term 1 · Jun–Oct"
        case 11, 12, 1, 2, 3: return "Term 2 · Nov–Mar"
        default: return "Term 3 · Apr–May"
        }
    }
}

// MARK: - UITableViewDelegate / UITableViewDataSource
extension leaverequestsVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredRequests.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "LeaverequestsTBLVCLL1", for: indexPath) as? LeaverequestsTBLVCLL1 else { return UITableViewCell() }
            cell.selectionStyle = .none
            cell.onFilterSelected = { [weak self] filter in
                self?.selectedFilter = filter
                self?.Tableview.reloadData()
            }
            cell.configure(
                totalRequests: totalRequestsCount, pendingCount: pendingCount, approvedCount: approvedCount,
                rejectedCount: rejectedCount, academicYear: academicYearText(), term: termWithRangeText(), selectedFilter: selectedFilter
            )
            return cell
        }

        let requestIndex = indexPath.row - 1
        guard filteredRequests.indices.contains(requestIndex),
              let cell = tableView.dequeueReusableCell(withIdentifier: "LeaverequestsTBLVCLL2", for: indexPath) as? LeaverequestsTBLVCLL2 else { return UITableViewCell() }

        cell.selectionStyle = .none
        cell.configure(with: filteredRequests[requestIndex], requestNumber: requestIndex + 1)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard indexPath.row > 0 else { return }
        let requestIndex = indexPath.row - 1
        guard filteredRequests.indices.contains(requestIndex) else { return }

        let item = filteredRequests[requestIndex]

        if item.status.caseInsensitiveCompare("REJECTED") == .orderedSame {
            openRejectDetail(for: item)
        } else if item.status.caseInsensitiveCompare("APPROVED") == .orderedSame {
            openApprovedDetail(for: item)
        }
    }

    // Maintained height at 245 so the storyboard labels for "This term" and "X requests" are perfectly visible
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? 245 : 92
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? 245 : 92
    }
}
