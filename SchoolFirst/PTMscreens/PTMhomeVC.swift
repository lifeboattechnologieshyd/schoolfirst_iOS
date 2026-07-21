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

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTopViewShadow()
        setupTableView()
        fetchPTMMeetings()
        fetchPTMCompletedMeetings()
    }
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


    // MARK: - Resolve School ID
    private func resolvedSchoolID() -> String {
        if let scid = UserManager.shared.selectedKid?.school?.schoolID, !scid.isEmpty { return scid }
        if let scid = UserManager.shared.selectedSchool?.schoolID, !scid.isEmpty { return scid }
        if let scid = UserDefaults.standard.string(forKey: "SCHOOL_ID"), !scid.isEmpty { return scid }
        if let scid = UserDefaults.standard.string(forKey: "SchoolID"), !scid.isEmpty { return scid }
        if let scid = UserDefaults.standard.string(forKey: "school_id"), !scid.isEmpty { return scid }
        if let data = UserDefaults.standard.data(forKey: "USER_INFO"),
           let user = try? JSONDecoder().decode(User.self, from: data),
           let scid = user.students?.first?.school?.schoolID, !scid.isEmpty { return scid }
        return ""
    }

    // MARK: - Resolve Student ID
    private func resolvedStudentID() -> String {
        if let sid = UserManager.shared.selectedKid?.studentID, !sid.isEmpty { return sid }
        if let sid = UserDefaults.standard.string(forKey: "STUDENT_ID"), !sid.isEmpty { return sid }
        if let data = UserDefaults.standard.data(forKey: "USER_INFO"),
           let user = try? JSONDecoder().decode(User.self, from: data),
           let sid = user.students?.first?.studentID, !sid.isEmpty { return sid }
        return ""
    }

    // MARK: - Navigate to PTMmeetingdetailsVC
    func navigateToPTMDetails(meeting: PTMMeeting? = nil) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let detailsVC = storyboard.instantiateViewController(withIdentifier: "PTMmeetingdetailsVC") as? PTMmeetingdetailsVC else { return }

        detailsVC.schoolID          = resolvedSchoolID()
        detailsVC.studentID         = resolvedStudentID()
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
        let schoolId  = resolvedSchoolID()
        let studentId = resolvedStudentID()

        guard !schoolId.isEmpty, !studentId.isEmpty else {
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
                    if response.success, let data = response.data {
                        self.ptmData = data
                    }
                    self.tableview.reloadData()
                case .failure:
                    self.tableview.reloadData()
                }
            }
        }
    }

    // MARK: - API: Completed Meetings
    private func fetchPTMCompletedMeetings() {
        isLoadingCompleted = true
        let schoolId  = resolvedSchoolID()
        let studentId = resolvedStudentID()

        guard !schoolId.isEmpty, !studentId.isEmpty else {
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
                }
                self.tableview.reloadData()
            }
        }
    }

    private func setupTableView() {
        tableview.delegate = self
        tableview.dataSource = self
        tableview.register(UINib(nibName: "PTMhomeTableViewCell1", bundle: nil), forCellReuseIdentifier: "PTMhomeTableViewCell1")
        tableview.register(UINib(nibName: "PTMhomeupcomingmeetingsTableViewCell", bundle: nil), forCellReuseIdentifier: "PTMhomeupcomingmeetingsTableViewCell")
        tableview.register(UINib(nibName: "PTMhomeTableViewCell1TableViewCell2", bundle: nil), forCellReuseIdentifier: "PTMhomeTableViewCell1TableViewCell2")
    }

    private func setupTopViewShadow() {
        Topview.layer.shadowColor = UIColor.lightGray.cgColor
        Topview.layer.shadowOpacity = 0.4
        Topview.layer.shadowOffset = CGSize(width: 0, height: 4)
        Topview.layer.shadowRadius = 2
        Topview.layer.masksToBounds = false
    }
}

extension PTMhomeVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading { return 3 }
        let meetingCount = ptmData?.meetings.count ?? 0
        return 1 + meetingCount + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let meetingCount = ptmData?.meetings.count ?? 0
        let lastRow = (meetingCount == 0) ? 2 : (1 + meetingCount)

        // ── Row 0: Header Cell ──
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PTMhomeTableViewCell1", for: indexPath) as! PTMhomeTableViewCell1
            cell.selectionStyle = .none

            if let student = ptmData?.student {
                cell.StudentnameLBl.text = "Hello, \(student.name)"
            }

            let count = ptmData?.meetings.count ?? 0
            if isLoading {
                cell.upcomingCountLabel.text = "Loading..."
            } else if count == 0 {
                cell.upcomingCountLabel.text = "No upcoming PTM meetings."
            } else {
                cell.upcomingCountLabel.text = "You have \(count) upcoming PTM\(count > 1 ? "s" : "") this week."
            }

            if let nextMeeting = ptmData?.meetings.first {
                cell.UpcomingmeetingDateLbl.text = nextMeeting.formattedDate
            } else {
                cell.UpcomingmeetingDateLbl.text = "No upcoming date"
            }

            if isLoadingCompleted {
                cell.TotalmeetingattendedcountLbl.text = "..."
            } else {
                cell.TotalmeetingattendedcountLbl.text = "\(completedData?.summary.attendedCount ?? 0)"
            }

            cell.onCalendarTapped = { [weak self] in
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let vc = storyboard.instantiateViewController(withIdentifier: "CalenderVC") as? CalenderVC {
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            }

            cell.onDetailsTapped = { [weak self] in
                self?.navigateToPTMDetails(meeting: nil)
            }

            return cell
        }

        // ── Last Row: Footer cell ──
        if indexPath.row == lastRow {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PTMhomeTableViewCell1TableViewCell2", for: indexPath) as! PTMhomeTableViewCell1TableViewCell2
            cell.configure(with: completedData?.meetings ?? [])
            return cell
        }

        // ── Middle Rows: Meeting Cells ──
        let cell = tableView.dequeueReusableCell(withIdentifier: "PTMhomeupcomingmeetingsTableViewCell", for: indexPath) as! PTMhomeupcomingmeetingsTableViewCell
        cell.configureParent(parentVC: self)
        let meetingIndex = indexPath.row - 1
        if let meeting = ptmData?.meetings[meetingIndex] {
            cell.configure(with: meeting, studentName: ptmData?.student.name ?? "Student", parentVC: self)
        }
        return cell
    }

    // MARK: - UPDATED: Dynamic height for footer cell
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let meetingCount = ptmData?.meetings.count ?? 0
        let lastRow = (meetingCount == 0) ? 2 : (1 + meetingCount)

        if indexPath.row == 0 { return 230 }

        // ── Footer row → dynamic height based on completed meetings ──
        if indexPath.row == lastRow {
            let completedCount = max(completedData?.meetings.count ?? 0, 1)
            let itemHeight: CGFloat = 100
            let spacing: CGFloat    = 1
            let verticalPadding: CGFloat = 40  // top + bottom breathing space

            let totalHeight = (CGFloat(completedCount) * itemHeight)
                            + (CGFloat(completedCount - 1) * spacing)
                            + verticalPadding

            print("📐 Footer row dynamic height → completed:", completedCount, "| height:", totalHeight)
            return totalHeight
        }

        return 330
    }
}
