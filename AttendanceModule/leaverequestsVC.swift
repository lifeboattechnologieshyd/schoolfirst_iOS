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

    @IBOutlet weak var Academicyearandterm: UILabel!
    @IBOutlet weak var Tableview: UITableView!
    @IBOutlet weak var Backbutton: UIButton!

    // MARK: - API Keys

    /*
     Backend showed: "Student ID is required."
     Some backends expect student_id, some expect student.
     Sending both prevents missing-param issue.
     */
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
        leaveRequests.filter {
            $0.status.caseInsensitiveCompare("PENDING") == .orderedSame
        }.count
    }

    private var approvedCount: Int {
        leaveRequests.filter {
            $0.status.caseInsensitiveCompare("APPROVED") == .orderedSame
        }.count
    }

    private var rejectedCount: Int {
        leaveRequests.filter {
            $0.status.caseInsensitiveCompare("REJECTED") == .orderedSame
        }.count
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()

        Backbutton.addTarget(
            self,
            action: #selector(didTapBackButton),
            for: .touchUpInside
        )

        Academicyearandterm.text = "\(academicYearText()) · \(termText())"

        fetchLeaveRequests()
    }

    // MARK: - Back Button

    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Table View

    private func setupTableView() {
        Tableview.delegate = self
        Tableview.dataSource = self
        Tableview.separatorStyle = .none
        Tableview.showsVerticalScrollIndicator = false
        Tableview.backgroundColor = UIColor(red: 0.95, green: 0.97, blue: 1.0, alpha: 1.0)
        Tableview.tableFooterView = UIView()

        let headerNib = UINib(
            nibName: "LeaverequestsTBLVCLL1",
            bundle: nil
        )

        Tableview.register(
            headerNib,
            forCellReuseIdentifier: "LeaverequestsTBLVCLL1"
        )

        let requestNib = UINib(
            nibName: "LeaverequestsTBLVCLL2",
            bundle: nil
        )

        Tableview.register(
            requestNib,
            forCellReuseIdentifier: "LeaverequestsTBLVCLL2"
        )
    }

    // MARK: - API

    private func fetchLeaveRequests() {
        let studentID = UserManager.shared.resolvedStudentID
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let schoolID = UserManager.shared.resolvedSchoolID
            .trimmingCharacters(in: .whitespacesAndNewlines)

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📤 Leave Requests API")
        print("studentID:", studentID)
        print("schoolID :", schoolID)
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        guard !studentID.isEmpty else {
            print("❌ Leave requests: studentID is empty")
            return
        }

        guard !schoolID.isEmpty else {
            print("❌ Leave requests: schoolID is empty")
            return
        }

        let completion: LeaveListCompletion = { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }

                switch result {
                case .success(let response):
                    if response.success {
                        self.leaveRequests = response.data?.data ?? []
                        self.totalRequestsCount =
                            response.total ?? self.leaveRequests.count

                        print("✅ Leave requests fetched:", self.leaveRequests.count)
                    } else {
                        self.leaveRequests = []
                        self.totalRequestsCount = 0
                        print("⚠️ Leave response failed:", response.description)
                    }

                    self.Tableview.reloadData()

                case .failure(let error):
                    print("❌ Leave requests error:", error.localizedDescription)

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
            parameters: [
                // Keep both to avoid backend mismatch.
                "student_id": studentID,
                "student": studentID
            ],
            headers: [
                schoolHeaderKey: schoolID
            ],
            completion: completion
        )
    }

    // MARK: - Academic / Term Helpers

    private func academicYearText() -> String {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: Date())
        let month = calendar.component(.month, from: Date())

        if month >= 6 {
            return "AY \(year)-\((year + 1) % 100)"
        } else {
            return "AY \(year - 1)-\(year % 100)"
        }
    }

    private func termText() -> String {
        let month = Calendar.current.component(.month, from: Date())

        switch month {
        case 6...10:
            return "Term 1"
        case 11, 12, 1, 2, 3:
            return "Term 2"
        default:
            return "Term 3"
        }
    }

    private func termWithRangeText() -> String {
        let month = Calendar.current.component(.month, from: Date())

        switch month {
        case 6...10:
            return "Term 1 · Jun–Oct"
        case 11, 12, 1, 2, 3:
            return "Term 2 · Nov–Mar"
        default:
            return "Term 3 · Apr–May"
        }
    }
}

// MARK: - UITableViewDelegate / UITableViewDataSource

extension leaverequestsVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        // Row 0 = summary/filter cell.
        return filteredRequests.count + 1
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "LeaverequestsTBLVCLL1",
                for: indexPath
            ) as? LeaverequestsTBLVCLL1 else {
                return UITableViewCell()
            }

            cell.selectionStyle = .none

            cell.onFilterSelected = { [weak self] filter in
                guard let self = self else { return }
                self.selectedFilter = filter
                self.Tableview.reloadData()
            }

            cell.configure(
                totalRequests: totalRequestsCount,
                pendingCount: pendingCount,
                approvedCount: approvedCount,
                rejectedCount: rejectedCount,
                academicYear: academicYearText(),
                term: termWithRangeText(),
                selectedFilter: selectedFilter
            )

            return cell
        }

        let requestIndex = indexPath.row - 1

        guard filteredRequests.indices.contains(requestIndex),
              let cell = tableView.dequeueReusableCell(
                withIdentifier: "LeaverequestsTBLVCLL2",
                for: indexPath
              ) as? LeaverequestsTBLVCLL2 else {
            return UITableViewCell()
        }

        cell.selectionStyle = .none
        cell.configure(
            with: filteredRequests[requestIndex],
            requestNumber: requestIndex + 1
        )

        return cell
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        if indexPath.row == 0 {
            return 200
        } else {
            return 92
        }
    }

    func tableView(
        _ tableView: UITableView,
        estimatedHeightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        if indexPath.row == 0 {
            return 200
        } else {
            return 92
        }
    }
}
