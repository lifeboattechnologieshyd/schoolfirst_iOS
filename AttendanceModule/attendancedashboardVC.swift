//
//  AttendancedashboardVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 21/10/26.
//

import UIKit

class attendancedashboardVC: UIViewController {

    @IBOutlet weak var Backbutton: UIButton!
    @IBOutlet weak var Tableview: UITableView!

    private var attendanceRecords: [FetchStudentAttendanceRecord] = []

    // Academic year to pass to the absent details screen.
    private var attendanceAcademicYear: FetchStudentAttendanceAcademicYear?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()

        Backbutton.addTarget(
            self,
            action: #selector(didTapBackButton),
            for: .touchUpInside
        )

        fetchAttendanceData()
    }

    // MARK: - Back Button Action
    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Setup TableView
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

    // MARK: - Fetch API Data
    private func fetchAttendanceData() {
        let endpoint = API.GET_STUDENT_ATTENDANCE

        let studentId = UserDefaults.standard.string(
            forKey: "STUDENT_ID"
        ) ?? ""

        let schoolId = UserDefaults.standard.string(
            forKey: "SCHOOL_ID"
        ) ?? ""

        let parameters: [String: Any] = [
            "student_id": studentId
        ]

        let headers: [String: String] = [
            "x-school-id": schoolId
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
                    self?.attendanceRecords =
                        response.data?.attendance ?? []

                    self?.attendanceAcademicYear =
                        response.data?.academicYear

                    self?.Tableview.reloadData()

                case .failure(let error):
                    print(
                        "Failed to fetch attendance: \(error.localizedDescription)"
                    )
                }
            }
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
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

    // MARK: - Open Attendance Details
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)

        // Ignore the dashboard cell.
        guard indexPath.row > 0 else {
            return
        }

        let recordIndex = indexPath.row - 1

        guard attendanceRecords.indices.contains(recordIndex) else {
            return
        }

        let selectedRecord = attendanceRecords[recordIndex]

        let status = (selectedRecord.status ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()

        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        switch status {

        case "ABSENT":
            // Existing absent navigation.
            guard let detailsVC = storyboard.instantiateViewController(
                withIdentifier: "AbsentdetailsVC"
            ) as? AbsentdetailsVC else {
                return
            }

            detailsVC.attendanceRecord = selectedRecord
            detailsVC.academicYear = attendanceAcademicYear

            navigationController?.pushViewController(
                detailsVC,
                animated: true
            )

        case "LATE":
            // Existing late navigation.
            guard let detailsVC = storyboard.instantiateViewController(
                withIdentifier: "LatearrivaldetailsVC"
            ) as? LatearrivaldetailsVC else {
                return
            }

            detailsVC.attendanceRecord = selectedRecord

            navigationController?.pushViewController(
                detailsVC,
                animated: true
            )

        case "PRESENT":
            // Open present details with the selected date's record.
            guard let detailsVC = storyboard.instantiateViewController(
                withIdentifier: "PresentdetailsVC"
            ) as? PresentdetailsVC else {
                return
            }

            detailsVC.attendanceRecord = selectedRecord

            navigationController?.pushViewController(
                detailsVC,
                animated: true
            )

        default:
            // No navigation for other attendance statuses.
            return
        }
    }

    // MARK: - Cell Height
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        if indexPath.row == 0 {
            return 920
        } else {
            return 76
        }
    }

    func tableView(
        _ tableView: UITableView,
        estimatedHeightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        if indexPath.row == 0 {
            return 920
        } else {
            return 76
        }
    }
}

// MARK: - AttendancedashboardTBLVCLLDelegate
extension attendancedashboardVC: AttendancedashboardTBLVCLLDelegate {

    func didTapApplyLeaveButton() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        if let leaveApplyVC = storyboard.instantiateViewController(
            withIdentifier: "LeaveapplyVC"
        ) as? LeaveapplyVC {
            navigationController?.pushViewController(
                leaveApplyVC,
                animated: true
            )
        }
    }

    // MARK: - Pending Leave Requests Navigation
    func didTapPendingLeaveRequests() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        guard let leaveRequestsVC = storyboard.instantiateViewController(
            withIdentifier: "leaverequestsVC"
        ) as? leaverequestsVC else {
            return
        }

        navigationController?.pushViewController(
            leaveRequestsVC,
            animated: true
        )
    }
}
