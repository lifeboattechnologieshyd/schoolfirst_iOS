//
//  PTMhomeVC.swift
//  SchoolFirst
//

import UIKit

class PTMhomeVC: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var NotificationButton: UIButton!
    @IBOutlet weak var BackButton: UIButton!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var Topview: UIView!

    // MARK: - Data
    private var ptmData: PTMResponseData?
    private var isLoading: Bool = true

    // ── Completed Meetings Data ─────────────────────────────────────
    private var completedData: PTMCompletedMeetingsResponse?
    private var isLoadingCompleted: Bool = true
    private var loadedStudentId: String = ""

    // MARK: - Computed Row Helpers
    private var meetingCount: Int {
        return ptmData?.meetings.count ?? 0
    }

    /// Row 0         → Header cell
    /// Rows 1..meetingCount → Meeting cells (0 if no meetings)
    /// Row meetingCount+1   → Footer cell
    private var footerRow: Int {
        return meetingCount + 1
    }

    private var totalRows: Int {
        return footerRow + 1  // header + meetings + footer
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTopViewShadow()
        setupTableView()
        fetchPTMMeetings()
        fetchPTMCompletedMeetings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let currentStudentId = UserManager.shared.resolvedStudentID
        if currentStudentId != loadedStudentId && !currentStudentId.isEmpty {
            print("🔄 PTM: Student changed to: \(currentStudentId)")
            fetchPTMMeetings()
            fetchPTMCompletedMeetings()
        }
    }

    // MARK: - Actions
    @IBAction func BackButtonTapped(_ sender: UIButton) {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    @IBAction func NotificationButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let notificationVC = storyboard.instantiateViewController(
            withIdentifier: "NotificationVC"
        ) as? NotificationVC {
            notificationVC.hidesBottomBarWhenPushed = true
            if let nav = navigationController {
                nav.setNavigationBarHidden(true, animated: false)
                nav.pushViewController(notificationVC, animated: true)
            } else {
                notificationVC.modalPresentationStyle = .fullScreen
                present(notificationVC, animated: true)
            }
        }
    }

    // MARK: - Navigate to PTMmeetingdetailsVC
    func navigateToPTMDetails(meeting: PTMMeeting? = nil) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let detailsVC = storyboard.instantiateViewController(
            withIdentifier: "PTMmeetingdetailsVC"
        ) as? PTMmeetingdetailsVC else { return }

        detailsVC.schoolID          = UserManager.shared.resolvedSchoolID
        detailsVC.studentID         = UserManager.shared.resolvedStudentID
        detailsVC.selectedMeeting   = meeting
        detailsVC.selectedMeetingID = meeting?.id

        if let nav = navigationController {
            nav.pushViewController(detailsVC, animated: true)
        } else {
            detailsVC.modalPresentationStyle = .fullScreen
            present(detailsVC, animated: true)
        }
    }

    // MARK: - API: Upcoming Meetings
    private func fetchPTMMeetings() {
        isLoading = true
        tableview.reloadData()

        let schoolId  = UserManager.shared.resolvedSchoolID
        let studentId = UserManager.shared.resolvedStudentID

        print("📡 PTM fetchPTMMeetings | schoolId: \(schoolId) | studentId: \(studentId)")

        guard !schoolId.isEmpty, !studentId.isEmpty else {
            print("❌ PTM: Missing schoolId or studentId")
            isLoading = false
            tableview.reloadData()
            return
        }

        NetworkManager.shared.request(
            urlString: API.PTM_MEETINGS,
            method: .GET,
            requiresAuth: true,
            parameters: ["student_id": studentId],
            headers: ["X-School-Id": schoolId]
        ) { [weak self] (result: Result<APIResponse<PTMResponseData>, NetworkError>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let response):
                    print("✅ PTM Meetings response: \(response)")
                    if response.success, let data = response.data {
                        self.ptmData = data
                        self.loadedStudentId = studentId
                    } else {
                        self.ptmData = nil
                    }
                case .failure(let error):
                    print("❌ PTM Meetings API failed: \(error)")
                    self.ptmData = nil
                }
                self.tableview.reloadData()
            }
        }
    }

    // MARK: - API: Completed Meetings
    private func fetchPTMCompletedMeetings() {
        isLoadingCompleted = true

        let schoolId  = UserManager.shared.resolvedSchoolID
        let studentId = UserManager.shared.resolvedStudentID

        print("📡 PTM fetchCompletedMeetings | schoolId: \(schoolId) | studentId: \(studentId)")

        guard !schoolId.isEmpty, !studentId.isEmpty else {
            print("❌ PTM Completed: Missing schoolId or studentId")
            isLoadingCompleted = false
            return
        }

        NetworkManager.shared.request(
            urlString: API.PTM_COMPLETED_MEETINGS,
            method: .GET,
            requiresAuth: true,
            parameters: ["student_id": studentId],
            headers: ["X-School-Id": schoolId]
        ) { [weak self] (result: Result<APIResponse<PTMCompletedMeetingsResponse>, NetworkError>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoadingCompleted = false
                if case .success(let response) = result, let data = response.data {
                    self.completedData = data
                } else {
                    self.completedData = nil
                }
                self.tableview.reloadData()
            }
        }
    }

    // MARK: - Setup
    private func setupTableView() {
        tableview.delegate = self
        tableview.dataSource = self
        tableview.register(
            UINib(nibName: "PTMhomeTableViewCell1", bundle: nil),
            forCellReuseIdentifier: "PTMhomeTableViewCell1"
        )
        tableview.register(
            UINib(nibName: "PTMhomeupcomingmeetingsTableViewCell", bundle: nil),
            forCellReuseIdentifier: "PTMhomeupcomingmeetingsTableViewCell"
        )
        tableview.register(
            UINib(nibName: "PTMhomeTableViewCell1TableViewCell2", bundle: nil),
            forCellReuseIdentifier: "PTMhomeTableViewCell1TableViewCell2"
        )
        tableview.separatorStyle = .none
        tableview.showsVerticalScrollIndicator = false
    }

    private func setupTopViewShadow() {
        Topview.layer.shadowColor = UIColor.lightGray.cgColor
        Topview.layer.shadowOpacity = 0.4
        Topview.layer.shadowOffset = CGSize(width: 0, height: 4)
        Topview.layer.shadowRadius = 2
        Topview.layer.masksToBounds = false
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension PTMhomeVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // While loading: show header + 1 skeleton meeting + footer = 3 rows
        if isLoading {
            return 3
        }
        // After load: header(1) + meetings(n, can be 0) + footer(1)
        return totalRows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row

        // ── Row 0: Header Cell ──────────────────────────────────────────
        if row == 0 {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "PTMhomeTableViewCell1",
                for: indexPath
            ) as! PTMhomeTableViewCell1
            cell.selectionStyle = .none

            if let student = ptmData?.student {
                cell.StudentnameLBl.text = "Hello, \(student.name)"
            } else {
                cell.StudentnameLBl.text = "Hello!"
            }

            if isLoading {
                cell.upcomingCountLabel.text = "Loading..."
            } else if meetingCount == 0 {
                cell.upcomingCountLabel.text = "No upcoming PTM meetings."
            } else {
                cell.upcomingCountLabel.text = "You have \(meetingCount) upcoming PTM\(meetingCount > 1 ? "s" : "") this week."
            }

            if let nextMeeting = ptmData?.meetings.first {
                cell.UpcomingmeetingDateLbl.text = nextMeeting.formattedDate
            } else {
                cell.UpcomingmeetingDateLbl.text = "No Meetings"
            }

            if isLoadingCompleted {
                cell.TotalmeetingattendedcountLbl.text = "..."
            } else {
                cell.TotalmeetingattendedcountLbl.text = "\(completedData?.summary.attendedCount ?? 0)"
            }

            cell.onCalendarTapped = { [weak self] in
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let vc = storyboard.instantiateViewController(
                    withIdentifier: "CalenderVC"
                ) as? CalenderVC {
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            }

            cell.onDetailsTapped = { [weak self] in
                self?.navigateToPTMDetails(meeting: nil)
            }

            return cell
        }

        // ── Footer Row: Completed Meetings Cell ─────────────────────────
        if row == footerRow {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "PTMhomeTableViewCell1TableViewCell2",
                for: indexPath
            ) as! PTMhomeTableViewCell1TableViewCell2
            cell.selectionStyle = .none
            cell.configure(with: completedData?.meetings ?? [])
            return cell
        }

        // ── Middle Rows: Upcoming Meeting Cells ─────────────────────────
        // Rows 1 to meetingCount
        let meetingIndex = row - 1

        // Safety guard — should never be out of range with correct numberOfRows
        guard meetingIndex >= 0,
              let meetings = ptmData?.meetings,
              meetingIndex < meetings.count else {
            print("⚠️ PTMhomeVC: meetingIndex \(meetingIndex) out of range (count: \(meetingCount)) — returning empty cell")
            return UITableViewCell()
        }

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "PTMhomeupcomingmeetingsTableViewCell",
            for: indexPath
        ) as! PTMhomeupcomingmeetingsTableViewCell
        cell.selectionStyle = .none
        cell.configureParent(parentVC: self)

        let meeting = meetings[meetingIndex]
        cell.configure(
            with: meeting,
            studentName: ptmData?.student.name ?? "Student",
            parentVC: self
        )

        return cell
    }

    // MARK: - Row Heights
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row

        // Header
        if row == 0 { return 230 }

        // Footer → dynamic height based on completed meetings count
        if row == footerRow {
            let completedCount = max(completedData?.meetings.count ?? 0, 1)
            let itemHeight: CGFloat     = 100
            let spacing: CGFloat        = 1
            let verticalPadding: CGFloat = 40

            let totalHeight = (CGFloat(completedCount) * itemHeight)
                            + (CGFloat(completedCount - 1) * spacing)
                            + verticalPadding

            print("📐 Footer row dynamic height → completed: \(completedCount) | height: \(totalHeight)")
            return totalHeight
        }

        // Meeting rows
        return 330
    }
}
