//
//  AttendancedashboardVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 21/10/26.
//

import UIKit

class attendancedashboardVC: UIViewController {

    @IBOutlet weak var Studentnameandgradelabel: UILabel!
    @IBOutlet weak var Backbutton: UIButton!
    @IBOutlet weak var Tableview: UITableView!

    private var attendanceRecords: [FetchStudentAttendanceRecord] = []
    private var attendanceAcademicYear: FetchStudentAttendanceAcademicYear?
    private var attendanceResponseData: FetchStudentAttendanceData?
    
    // Properties for Pending Leave Requests
    private var pendingLeaveCount: Int = 0
    private var lastLeaveReason: String = ""
    private var lastLeaveStatus: String = ""
    
    // Passed from Homescreen while navigating
    var studentNameAndGradeInfo: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        
        // Configure the Student Name & Grade Label
        if let info = studentNameAndGradeInfo, !info.isEmpty {
            Studentnameandgradelabel.text = info
        } else {
            // Fallback just in case
            Studentnameandgradelabel.text = "\(UserManager.shared.resolvedStudentName) | \(UserManager.shared.resolvedGradeSection)"
        }

        Backbutton.addTarget(
            self,
            action: #selector(didTapBackButton),
            for: .touchUpInside
        )

        fetchAttendanceData()
        fetchLeaveRequests() // New call to populate the pending leave cards UI
    }

    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }

    private func setupTableView() {
        Tableview.delegate = self
        Tableview.dataSource = self
        Tableview.separatorStyle = .none
        Tableview.showsVerticalScrollIndicator = false

        let nib = UINib(
            nibName: "attendancedashboardTBLVCLL",
            bundle: nil
        )

        Tableview.register(
            nib,
            forCellReuseIdentifier: "attendancedashboardTBLVCLL"
        )

        let leaveRequestsNib = UINib(
            nibName: "absentpresentlateTBLVCLL",
            bundle: nil
        )

        Tableview.register(
            leaveRequestsNib,
            forCellReuseIdentifier: "absentpresentlateTBLVCLL"
        )

        Tableview.tableFooterView = UIView()
    }

    private func fetchAttendanceData() {
        let endpoint = API.GET_STUDENT_ATTENDANCE

        // USE USERMANAGER INSTEAD OF USERDEFAULTS (Per your requirements)
        let studentId = UserManager.shared.resolvedStudentID
        let schoolId = UserManager.shared.resolvedSchoolID

        guard !studentId.isEmpty, !schoolId.isEmpty else { return }

        let parameters: [String: Any] = [
            "student_id": studentId
        ]

        let headers: [String: String] = [
            "X-School-ID": schoolId
        ]

        NetworkManager.shared.request(
            urlString: endpoint,
            method: .GET,
            requiresAuth: true,
            parameters: parameters,
            headers: headers
        ) { [weak self] (
            result: Result<APIResponse<FetchStudentAttendanceData>, NetworkError>
        ) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.attendanceResponseData = response.data
                    self?.attendanceRecords = response.data?.attendance ?? []
                    self?.attendanceAcademicYear = response.data?.academicYear
                    self?.Tableview.reloadData()

                case .failure(let error):
                    print("Failed to fetch attendance: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // FETCH LEAVE REQUESTS FOR THE UI CARDS (Figma Requirement)
    private func fetchLeaveRequests() {
        let studentID = UserManager.shared.resolvedStudentID
        let schoolID = UserManager.shared.resolvedSchoolID
        
        guard !studentID.isEmpty, !schoolID.isEmpty else { return }
        
        NetworkManager.shared.request(
            urlString: API.STUDENT_LEAVE_REQUESTS,
            method: .GET,
            requiresAuth: true,
            parameters: ["student_id": studentID, "student": studentID],
            headers: ["X-School-ID": schoolID]
        ) { [weak self] (result: Result<APIResponse<LeaveListDataWrapper>, NetworkError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    let requests = response.data?.data ?? []
                    
                    // Count only pending requests
                    let pending = requests.filter { $0.status.caseInsensitiveCompare("PENDING") == .orderedSame }
                    self?.pendingLeaveCount = pending.count
                    
                    // Store the details of the latest request
                    if let first = requests.first {
                        // Assuming your model has .reason, adjust to .title or .leaveType if necessary
                        self?.lastLeaveReason = first.reason ?? "Leave Request"
                        self?.lastLeaveStatus = first.status.capitalized
                    } else {
                        self?.lastLeaveReason = ""
                        self?.lastLeaveStatus = ""
                    }
                    
                    // Refresh just the top cell where the leaves view exists
                    self?.Tableview.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                    
                case .failure(let error):
                    print("Failed to fetch leave requests: \(error.localizedDescription)")
                }
            }
        }
    }

    // Helper: find record for today from attendance array
    private func todayRecord() -> FetchStudentAttendanceRecord? {
        guard let records = attendanceResponseData?.attendance else { return nil }
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        fmt.locale = Locale(identifier: "en_US_POSIX")
        let todayStr = fmt.string(from: Date())
        
        return records.first { $0.attendanceDate == todayStr }
    }
}

extension attendancedashboardVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return 1 + attendanceRecords.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "attendancedashboardTBLVCLL",
                for: indexPath
            ) as? attendancedashboardTBLVCLL else {
                return UITableViewCell()
            }

            cell.selectionStyle = .none
            cell.delegate = self
            
            // Pass all required data directly to cell
            cell.configure(
                with: attendanceResponseData,
                todayRecord: todayRecord(),
                pendingLeaveCount: pendingLeaveCount,
                lastLeaveReason: lastLeaveReason,
                lastLeaveStatus: lastLeaveStatus
            )

            return cell

        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "absentpresentlateTBLVCLL",
                for: indexPath
            ) as? absentpresentlateTBLVCLL else {
                return UITableViewCell()
            }

            let record = attendanceRecords[indexPath.row - 1]
            cell.configure(with: record)

            return cell
        }
    }

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard indexPath.row > 0 else { return }

        let recordIndex = indexPath.row - 1
        guard attendanceRecords.indices.contains(recordIndex) else { return }

        let selectedRecord = attendanceRecords[recordIndex]

        let status = (selectedRecord.status ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()

        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        switch status {

        case "ABSENT":
            guard let detailsVC = storyboard.instantiateViewController(
                withIdentifier: "AbsentdetailsVC"
            ) as? AbsentdetailsVC else { return }
            detailsVC.attendanceRecord = selectedRecord
            detailsVC.academicYear = attendanceAcademicYear
            navigationController?.pushViewController(detailsVC, animated: true)

        case "LATE":
            guard let detailsVC = storyboard.instantiateViewController(
                withIdentifier: "LatearrivaldetailsVC"
            ) as? LatearrivaldetailsVC else { return }
            detailsVC.attendanceRecord = selectedRecord
            navigationController?.pushViewController(detailsVC, animated: true)

        case "PRESENT":
            guard let detailsVC = storyboard.instantiateViewController(
                withIdentifier: "PresentdetailsVC"
            ) as? PresentdetailsVC else { return }
            detailsVC.attendanceRecord = selectedRecord
            navigationController?.pushViewController(detailsVC, animated: true)

        default:
            return
        }
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return indexPath.row == 0 ? 920 : 76
    }

    func tableView(
        _ tableView: UITableView,
        estimatedHeightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return indexPath.row == 0 ? 920 : 76
    }
}

extension attendancedashboardVC: AttendancedashboardTBLVCLLDelegate {

    func didTapApplyLeaveButton() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let leaveApplyVC = storyboard.instantiateViewController(
            withIdentifier: "LeaveapplyVC"
        ) as? LeaveapplyVC {
            navigationController?.pushViewController(leaveApplyVC, animated: true)
        }
    }

    func didTapPendingLeaveRequests() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let leaveRequestsVC = storyboard.instantiateViewController(
            withIdentifier: "leaverequestsVC"
        ) as? leaverequestsVC else { return }
        navigationController?.pushViewController(leaveRequestsVC, animated: true)
    }

    func didTapHistoryButton() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let weeklyVC = storyboard.instantiateViewController(
            withIdentifier: "WeaklyattendanceVC"
        ) as? WeaklyattendanceVC {
            weeklyVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(weeklyVC, animated: true)
        }
    }
}
