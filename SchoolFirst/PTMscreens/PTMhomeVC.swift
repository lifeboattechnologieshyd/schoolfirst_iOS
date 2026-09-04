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

    // ✅ NEW: Store completed meeting IDs to filter them out
    private var completedMeetingIDs: Set<String> = []

    // ✅ NEW: Filtered meetings (excluding completed ones)
    private var filteredMeetings: [PTMMeeting] = []

    // MARK: - Computed Row Helpers
    private var meetingCount: Int {
        return filteredMeetings.count  // ✅ Use filtered count
    }

    private var footerRow: Int {
        return meetingCount + 1
    }

    private var totalRows: Int {
        return footerRow + 1
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

        detailsVC.studentName       = ptmData?.student.name ?? ""

        print("🚀 Navigating to PTMmeetingdetailsVC")
        print("   meetingID  : \(meeting?.id   ?? "nil")")
        print("   studentName: \(detailsVC.studentName)")

        if let nav = navigationController {
            nav.pushViewController(detailsVC, animated: true)
        } else {
            detailsVC.modalPresentationStyle = .fullScreen
            present(detailsVC, animated: true)
        }
    }

    // MARK: - Navigate to attendedhistoryVC
    private func navigateToAttendedHistory() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        guard let vc = storyboard.instantiateViewController(
            withIdentifier: "attendedhistoryVC"
        ) as? attendedhistoryVC else {
            print("❌ attendedhistoryVC not found. Check Storyboard ID.")
            return
        }

        print("🚀 Navigating to attendedhistoryVC")

        if let nav = navigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
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

        let baseUrl = API.PTM_MEETINGS
        let urlString = baseUrl.contains("?")
            ? "\(baseUrl)&student_id=\(studentId)"
            : "\(baseUrl)?student_id=\(studentId)"

        NetworkManager.shared.request(
            urlString: urlString,
            method: .GET,
            requiresAuth: true,
            parameters: nil,
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
                        self.applyFilter()  // ✅ Apply filter after both APIs load
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

        let baseUrl = API.PTM_COMPLETED_MEETINGS
        let urlString = baseUrl.contains("?")
            ? "\(baseUrl)&student_id=\(studentId)"
            : "\(baseUrl)?student_id=\(studentId)"

        NetworkManager.shared.request(
            urlString: urlString,
            method: .GET,
            requiresAuth: true,
            parameters: nil,
            headers: ["X-School-Id": schoolId]
        ) { [weak self] (result: Result<APIResponse<PTMCompletedMeetingsResponse>, NetworkError>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoadingCompleted = false
                if case .success(let response) = result, let data = response.data {
                    self.completedData = data

                    // ✅ Build Set of completed meeting IDs
                    self.completedMeetingIDs = Set(data.meetings.map { $0.id })
                    print("   Completed meeting IDs: \(self.completedMeetingIDs.count)")

                    self.applyFilter()  // ✅ Apply filter after both APIs load
                } else {
                    self.completedData = nil
                }
                self.tableview.reloadData()
            }
        }
    }

    // MARK: - ✅ NEW: Filter Meetings (Exclude Completed)
    private func applyFilter() {
        guard let allMeetings = ptmData?.meetings else {
            filteredMeetings = []
            return
        }

        // ✅ Only include meetings NOT in completed list
        filteredMeetings = allMeetings.filter { meeting in
            !completedMeetingIDs.contains(meeting.id)
        }

        print("🔍 Filtered meetings: \(filteredMeetings.count) of \(allMeetings.count)")
        print("   Excluded: \(allMeetings.count - filteredMeetings.count) completed meetings")
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
        if isLoading {
            return 3
        }
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

            // Configure labels dynamically depending on the presence of upcoming meetings
            if isLoading {
                cell.upcomingCountLabel.text = "Loading..."
                cell.UpcomingmeetingsLbl.text = "Upcoming Meetings"
            } else if meetingCount == 0 {
                cell.upcomingCountLabel.text = "No upcoming PTM meetings."
<<<<<<< HEAD
                cell.UpcomingmeetingsLbl.text = "No Upcoming Meetings"
            } else {
                cell.upcomingCountLabel.text = "You have \(meetingCount) upcoming PTM\(meetingCount > 1 ? "s" : "") this week."
                cell.UpcomingmeetingsLbl.text = "Upcoming Meetings"
=======
                cell.UpcomingmeetingsLbl.text = "No Upcoming Meetings" // ✅ Updated to show custom empty state
            } else {
                cell.upcomingCountLabel.text = "You have \(meetingCount) upcoming PTM\(meetingCount > 1 ? "s" : "") this week."
                cell.UpcomingmeetingsLbl.text = "Upcoming Meetings" // ✅ Restored original name
>>>>>>> origin/schoolzone
            }

            // ✅ Use filtered meetings for "next meeting" date
            if let nextMeeting = filteredMeetings.first {
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

<<<<<<< HEAD
=======
            // Totalattendedview tap → attendedhistoryVC
>>>>>>> origin/schoolzone
            cell.onAttendedHistoryTapped = { [weak self] in
                self?.navigateToAttendedHistory()
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
        let meetingIndex = row - 1

        // ✅ Safety guard using filteredMeetings
        guard meetingIndex >= 0,
              meetingIndex < filteredMeetings.count else {
            print("⚠️ PTMhomeVC: meetingIndex \(meetingIndex) out of range (count: \(meetingCount)) — returning empty cell")
            return UITableViewCell()
        }

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "PTMhomeupcomingmeetingsTableViewCell",
            for: indexPath
        ) as! PTMhomeupcomingmeetingsTableViewCell
        cell.selectionStyle = .none
        cell.configureParent(parentVC: self)

        let meeting = filteredMeetings[meetingIndex]  // ✅ Use filtered list
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

        if row == 0 { return 230 }

        if row == footerRow {
            if isLoadingCompleted {
                return 120
            }
            
            let completedCount = completedData?.meetings.count ?? 0
            if completedCount == 0 {
<<<<<<< HEAD
=======
                // Dynamic empty height set to 100 to let the placeholder sit beautifully
>>>>>>> origin/schoolzone
                print("📐 Footer row height → empty state: 100")
                return 100
            }

            let itemHeight: CGFloat     = 81
            let spacing: CGFloat        = 1
            let verticalPadding: CGFloat = 40

            let totalHeight = (CGFloat(completedCount) * itemHeight)
                            + (CGFloat(completedCount - 1) * spacing)
                            + verticalPadding

            print("📐 Footer row dynamic height → completed: \(completedCount) | height: \(totalHeight)")
            return totalHeight
        }

        return 330
    }
}
