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

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTopViewShadow()
        setupTableView()
        fetchPTMMeetings()
    }

    // MARK: - Resolve School ID
    private func resolvedSchoolID() -> String {

        // Priority 1: UserManager in-memory selectedKid's school
        if let scid = UserManager.shared.selectedKid?.school?.schoolID,
           !scid.isEmpty {
            print("✅ resolvedSchoolID → from selectedKid.school:", scid)
            return scid
        }

        // Priority 2: UserManager selectedSchool
        if let scid = UserManager.shared.selectedSchool?.schoolID,
           !scid.isEmpty {
            print("✅ resolvedSchoolID → from selectedSchool:", scid)
            return scid
        }

        // Priority 3: UserDefaults SCHOOL_ID
        if let scid = UserDefaults.standard.string(forKey: "SCHOOL_ID"),
           !scid.isEmpty {
            print("✅ resolvedSchoolID → from UserDefaults[SCHOOL_ID]:", scid)
            return scid
        }

        // Priority 4: UserDefaults SchoolID
        if let scid = UserDefaults.standard.string(forKey: "SchoolID"),
           !scid.isEmpty {
            print("✅ resolvedSchoolID → from UserDefaults[SchoolID]:", scid)
            return scid
        }

        // Priority 5: UserDefaults school_id
        if let scid = UserDefaults.standard.string(forKey: "school_id"),
           !scid.isEmpty {
            print("✅ resolvedSchoolID → from UserDefaults[school_id]:", scid)
            return scid
        }

        // Priority 6: Decode from USER_INFO
        if let data = UserDefaults.standard.data(forKey: "USER_INFO"),
           let user = try? JSONDecoder().decode(User.self, from: data),
           let scid = user.students?.first?.school?.schoolID,
           !scid.isEmpty {
            print("✅ resolvedSchoolID → from USER_INFO decode:", scid)
            return scid
        }

        print("❌ resolvedSchoolID → all sources empty")
        return ""
    }

    // MARK: - Resolve Student ID
    private func resolvedStudentID() -> String {

        // Priority 1: UserManager in-memory selectedKid
        if let sid = UserManager.shared.selectedKid?.studentID,
           !sid.isEmpty {
            print("✅ resolvedStudentID → from selectedKid:", sid)
            return sid
        }

        // Priority 2: UserDefaults STUDENT_ID
        if let sid = UserDefaults.standard.string(forKey: "STUDENT_ID"),
           !sid.isEmpty {
            print("✅ resolvedStudentID → from UserDefaults[STUDENT_ID]:", sid)
            return sid
        }

        // Priority 3: Decode from USER_INFO
        if let data = UserDefaults.standard.data(forKey: "USER_INFO"),
           let user = try? JSONDecoder().decode(User.self, from: data),
           let sid = user.students?.first?.studentID,
           !sid.isEmpty {
            print("✅ resolvedStudentID → from USER_INFO decode:", sid)
            return sid
        }

        print("❌ resolvedStudentID → all sources empty")
        return ""
    }

    // MARK: - Navigate to PTMmeetingdetailsVC
    func navigateToPTMDetails(meeting: PTMMeeting? = nil) {

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("🚀 navigateToPTMDetails called")
        print("   meeting   :", meeting?.title ?? "nil → show all")
        print("   meetingID :", meeting?.id    ?? "nil → show all")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        guard let detailsVC = storyboard.instantiateViewController(
            withIdentifier: "PTMmeetingdetailsVC"
        ) as? PTMmeetingdetailsVC else {
            print("❌ PTMmeetingdetailsVC not found — check storyboard identifier")
            return
        }

        // ── Pass resolved IDs ────────────────────────────────────────────
        detailsVC.schoolID          = resolvedSchoolID()
        detailsVC.studentID         = resolvedStudentID()
        detailsVC.selectedMeeting   = meeting
        detailsVC.selectedMeetingID = meeting?.id

        print("📌 Passing to PTMmeetingdetailsVC:")
        print("   schoolID  :", detailsVC.schoolID.isEmpty  ? "⚠️ EMPTY" : detailsVC.schoolID)
        print("   studentID :", detailsVC.studentID.isEmpty ? "⚠️ EMPTY" : detailsVC.studentID)
        print("   meetingID :", detailsVC.selectedMeetingID ?? "nil")

        if let nav = navigationController {
            nav.pushViewController(detailsVC, animated: true)
        } else {
            print("⚠️ navigationController is nil — presenting modally")
            detailsVC.modalPresentationStyle = .fullScreen
            present(detailsVC, animated: true)
        }
    }

    // MARK: - Actions
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

    @IBAction func BackButtonTapped(_ sender: UIButton) {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    // MARK: - API
    private func fetchPTMMeetings() {
        isLoading = true
        tableview.reloadData()

        let schoolId  = resolvedSchoolID()
        let studentId = resolvedStudentID()

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("🌐 PTMhomeVC — fetchPTMMeetings()")
        print("   schoolId  :", schoolId.isEmpty  ? "⚠️ EMPTY" : schoolId)
        print("   studentId :", studentId.isEmpty ? "⚠️ EMPTY" : studentId)
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        guard !schoolId.isEmpty, !studentId.isEmpty else {
            print("❌ PTMhomeVC — cannot fetch, IDs are empty")
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
                        print("✅ PTM meetings fetched:", data.meetings.count, "meeting(s)")
                        print("   Student name :", data.student.name)
                    } else {
                        print("⚠️ PTM API returned success=false or nil data")
                    }
                    self.tableview.reloadData()

                case .failure(let error):
                    print("❌ PTM API error:", error)
                    self.tableview.reloadData()
                }
            }
        }
    }

    // MARK: - TableView Setup
    private func setupTableView() {
        tableview.delegate   = self
        tableview.dataSource = self
        tableview.separatorStyle               = .none
        tableview.showsVerticalScrollIndicator = false

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
    }

    // MARK: - Shadow
    private func setupTopViewShadow() {
        Topview.layer.shadowColor   = UIColor.lightGray.cgColor
        Topview.layer.shadowOpacity = 0.4
        Topview.layer.shadowOffset  = CGSize(width: 0, height: 4)
        Topview.layer.shadowRadius  = 2
        Topview.layer.masksToBounds = false
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension PTMhomeVC: UITableViewDelegate, UITableViewDataSource {

    // MARK: - Row Count
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        if isLoading { return 3 }

        let meetingCount = ptmData?.meetings.count ?? 0
        if meetingCount == 0 { return 3 }

        // Row 0        → Header cell
        // Row 1...n    → Meeting cells
        // Row n+1      → Footer cell
        return 1 + meetingCount + 1
    }

    // MARK: - Cell For Row
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let meetingCount = ptmData?.meetings.count ?? 0
        let lastRow      = (meetingCount == 0) ? 2 : (1 + meetingCount)

        // ── Row 0 → Header cell ──────────────────────────────────────────
        if indexPath.row == 0 {
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

            let count = ptmData?.meetings.count ?? 0
            if isLoading {
                cell.upcomingCountLabel.text = "Loading your PTM meetings..."
            } else if count == 0 {
                cell.upcomingCountLabel.text = "No upcoming PTM meetings this week."
            } else if count == 1 {
                cell.upcomingCountLabel.text = "You have 1 upcoming PTM this week."
            } else {
                cell.upcomingCountLabel.text = "You have \(count) upcoming PTMs this week."
            }

            // Calendar tap → CalendarVC
            cell.onCalendarTapped = { [weak self] in
                guard let self = self else { return }
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let calendarVC = storyboard.instantiateViewController(
                    withIdentifier: "CalenderVC"
                ) as? CalenderVC {
                    if let nav = self.navigationController {
                        nav.pushViewController(calendarVC, animated: true)
                    } else {
                        calendarVC.modalPresentationStyle = .fullScreen
                        self.present(calendarVC, animated: true)
                    }
                }
            }

            // Details tap → show ALL meetings
            cell.onDetailsTapped = { [weak self] in
                guard let self = self else { return }
                self.navigateToPTMDetails(meeting: nil)
            }

            return cell
        }

        // ── Last Row → Footer cell ───────────────────────────────────────
        if indexPath.row == lastRow {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "PTMhomeTableViewCell1TableViewCell2",
                for: indexPath
            ) as! PTMhomeTableViewCell1TableViewCell2

            cell.selectionStyle = .none
            cell.configure(with: [1, 2, 3])
            return cell
        }

        // ── Middle rows → Meeting cells ──────────────────────────────────
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "PTMhomeupcomingmeetingsTableViewCell",
            for: indexPath
        ) as! PTMhomeupcomingmeetingsTableViewCell

        cell.selectionStyle = .none

        // Always set parentVC first
        cell.configureParent(parentVC: self)

        let meetingIndex = indexPath.row - 1

        if meetingCount > 0,
           meetingIndex >= 0,
           meetingIndex < meetingCount,
           let meeting = ptmData?.meetings[meetingIndex] {

            let studentName = ptmData?.student.name ?? "Student"
            cell.configure(with: meeting, studentName: studentName, parentVC: self)
        }

        return cell
    }

    // MARK: - didSelectRowAt
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)

        let meetingCount = ptmData?.meetings.count ?? 0
        let lastRow      = (meetingCount == 0) ? 2 : (1 + meetingCount)

        // Ignore header and footer rows
        guard indexPath.row != 0,
              indexPath.row != lastRow else { return }

        let meetingIndex = indexPath.row - 1

        guard meetingCount > 0,
              meetingIndex >= 0,
              meetingIndex < meetingCount,
              let meeting = ptmData?.meetings[meetingIndex] else { return }

        print("✅ Meeting cell tapped:", meeting.title, "| id:", meeting.id)
        navigateToPTMDetails(meeting: meeting)
    }

    // MARK: - Row Heights
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        let meetingCount = ptmData?.meetings.count ?? 0
        let lastRow      = (meetingCount == 0) ? 2 : (1 + meetingCount)

        if indexPath.row == 0       { return 230 }
        if indexPath.row == lastRow { return 350 }
        return 330
    }
}
