//
//  PTMmeetingdetailsVC.swift
//  SchoolFirst
//

import UIKit

class PTMmeetingdetailsVC: UIViewController {
 
    // MARK: - Outlets
    @IBOutlet weak var BackButton: UIButton!
    @IBOutlet weak var TopView: UIView!
    @IBOutlet weak var tableview: UITableView!

    // MARK: - Passed from PTMhomeVC
    var schoolID: String = ""
    var studentID: String = ""
    var selectedMeeting: PTMMeeting?
    var selectedMeetingID: String?

    // MARK: - Data
    private var ptmData: PTMResponseData?
    private var displayMeetings: [PTMMeeting] = []
    private var isLoading: Bool = false

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTopViewShadow()
        setupTableView()
        resolveIDsAndFetch()
    }

    // MARK: - Resolve IDs
    private func resolveIDsAndFetch() {

        if schoolID.isEmpty {
            if let scid = UserManager.shared.selectedKid?.school?.schoolID, !scid.isEmpty {
                schoolID = scid
                print("🔄 schoolID recovered from selectedKid.school:", schoolID)
            } else if let scid = UserManager.shared.selectedSchool?.schoolID, !scid.isEmpty {
                schoolID = scid
                print("🔄 schoolID recovered from selectedSchool:", schoolID)
            } else if let scid = UserDefaults.standard.string(forKey: "SCHOOL_ID"), !scid.isEmpty {
                schoolID = scid
                print("🔄 schoolID recovered from UserDefaults[SCHOOL_ID]:", schoolID)
            } else if let scid = UserDefaults.standard.string(forKey: "SchoolID"), !scid.isEmpty {
                schoolID = scid
                print("🔄 schoolID recovered from UserDefaults[SchoolID]:", schoolID)
            } else if let scid = UserDefaults.standard.string(forKey: "school_id"), !scid.isEmpty {
                schoolID = scid
                print("🔄 schoolID recovered from UserDefaults[school_id]:", schoolID)
            } else if let data = UserDefaults.standard.data(forKey: "USER_INFO"),
                      let user = try? JSONDecoder().decode(User.self, from: data),
                      let scid = user.students?.first?.school?.schoolID,
                      !scid.isEmpty {
                schoolID = scid
                print("🔄 schoolID recovered from USER_INFO decode:", schoolID)
            }
        }

        if studentID.isEmpty {
            if let sid = UserManager.shared.selectedKid?.studentID, !sid.isEmpty {
                studentID = sid
                print("🔄 studentID recovered from selectedKid:", studentID)
            } else if let sid = UserDefaults.standard.string(forKey: "STUDENT_ID"), !sid.isEmpty {
                studentID = sid
                print("🔄 studentID recovered from UserDefaults[STUDENT_ID]:", studentID)
            } else if let data = UserDefaults.standard.data(forKey: "USER_INFO"),
                      let user = try? JSONDecoder().decode(User.self, from: data),
                      let sid = user.students?.first?.studentID,
                      !sid.isEmpty {
                studentID = sid
                print("🔄 studentID recovered from USER_INFO decode:", studentID)
            }
        }

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📌 PTMmeetingdetailsVC — resolveIDsAndFetch()")
        print("   schoolID         :", schoolID.isEmpty  ? "⚠️ EMPTY" : schoolID)
        print("   studentID        :", studentID.isEmpty ? "⚠️ EMPTY" : studentID)
        print("   selectedMeetingID:", selectedMeetingID ?? "nil → show all")
        print("   selectedMeeting  :", selectedMeeting?.id ?? "nil → show all")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        guard !schoolID.isEmpty, !studentID.isEmpty else {
            print("❌ schoolID or studentID still empty after all fallbacks")
            showErrorAlert("Unable to load meeting details. Please go back and try again.")
            return
        }

        fetchPTMMeetings()
    }

    // MARK: - API Call
    private func fetchPTMMeetings() {
        isLoading = true
        tableview.reloadData()

        print("🌐 PTM Details API Request")
        print("   Endpoint    :", API.PTM_MEETINGS)
        print("   student_id  :", studentID)
        print("   X-School-Id :", schoolID)

        NetworkManager.shared.request(
            urlString: API.PTM_MEETINGS,
            method: .GET,
            requiresAuth: true,
            parameters: ["student_id": studentID],
            headers: ["X-School-Id": schoolID]
        ) { [weak self] (result: Result<APIResponse<PTMResponseData>, NetworkError>) in

            guard let self = self else { return }

            DispatchQueue.main.async {
                self.isLoading = false

                switch result {
                case .success(let response):
                    self.handleSuccess(response)

                case .failure(let error):
                    self.handleFailure(error)
                }
            }
        }
    }

    // MARK: - Success Handler
    private func handleSuccess(_ response: APIResponse<PTMResponseData>) {

        guard let data = response.data else {
            print("❌ PTM response.data is nil")
            displayMeetings = []
            tableview.reloadData()
            return
        }

        ptmData = data

        print("✅ PTM details fetch success")
        print("   Student name  :", data.student.name)
        print("   Total meetings:", data.meetings.count)

        let targetID = selectedMeetingID ?? selectedMeeting?.id

        if let id = targetID {
            displayMeetings = data.meetings.filter { $0.id == id }
            print("   Filtered by id:", id, "→ found:", displayMeetings.count)

            if displayMeetings.isEmpty {
                print("⚠️ No meeting matched id:", id)
                print("   Available IDs:", data.meetings.map { $0.id })
                displayMeetings = data.meetings
                print("   Fallback → showing all:", displayMeetings.count)
            }
        } else {
            displayMeetings = data.meetings
            print("   Showing all meetings:", displayMeetings.count)
        }

        tableview.isHidden = false
        tableview.reloadData()
        tableview.layoutIfNeeded()
    }

    // MARK: - Failure Handler
    private func handleFailure(_ error: NetworkError) {
        print("❌ PTM details fetch failed:", error)
        displayMeetings = []
        tableview.reloadData()

        switch error {
        case .noInternet:
            showErrorAlert("No internet connection. Please check your network.")
        case .noaccess:
            showErrorAlert("Session expired. Please log in again.")
        case .decodingError(let msg):
            showErrorAlert("Data error: \(msg)")
        default:
            showErrorAlert("Failed to load meeting details. Please try again.")
        }
    }

    // MARK: - Error Alert
    private func showErrorAlert(_ message: String) {
        let alert = UIAlertController(
            title: "Oops!",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
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

    // MARK: - Setup
    private func setupTopViewShadow() {
        TopView.layer.shadowColor   = UIColor.lightGray.cgColor
        TopView.layer.shadowOpacity = 0.4
        TopView.layer.shadowOffset  = CGSize(width: 0, height: 4)
        TopView.layer.shadowRadius  = 2
        TopView.layer.masksToBounds = false
    }

    private func setupTableView() {
        tableview.delegate   = self
        tableview.dataSource = self

        tableview.register(
            UINib(nibName: "PTMmeetingdetailsTableViewCell", bundle: nil),
            forCellReuseIdentifier: "PTMmeetingdetailsTableViewCell"
        )

        tableview.separatorStyle               = .none
        tableview.showsVerticalScrollIndicator = false

        // IMPORTANT: fixed height to avoid collapsed auto-layout cell
        tableview.rowHeight          = 430
        tableview.estimatedRowHeight = 430

        tableview.isHidden = false
        tableview.reloadData()
    }
}

// MARK: - UITableViewDelegate & DataSource
extension PTMmeetingdetailsVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        if isLoading { return 1 }
        if displayMeetings.isEmpty { return 1 }

        print("📊 PTM Details numberOfRows =", displayMeetings.count)
        return displayMeetings.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        if isLoading {
            return makeSpinnerCell(tableView)
        }

        if displayMeetings.isEmpty {
            return makeEmptyCell(tableView, message: "No meeting details found.")
        }

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "PTMmeetingdetailsTableViewCell",
            for: indexPath
        ) as? PTMmeetingdetailsTableViewCell else {
            print("❌ Failed to dequeue PTMmeetingdetailsTableViewCell")
            return UITableViewCell()
        }

        cell.selectionStyle = .none

        guard let student = ptmData?.student,
              indexPath.row < displayMeetings.count else {
            print("❌ ptmData.student nil or invalid row")
            return cell
        }

        let meeting = displayMeetings[indexPath.row]

        print("📋 Configuring details cell")
        print("   row        :", indexPath.row)
        print("   student    :", student.name)
        print("   meeting    :", meeting.title)
        print("   meeting id :", meeting.id)

        cell.configure(meeting: meeting, student: student)

        cell.onConfirmTap = { [weak self] in
            guard let self = self else { return }
            self.navigateToConfirmation(meeting: meeting)
        }

        return cell
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        if isLoading || displayMeetings.isEmpty {
            return 150
        }
        return 1400
    }

    // MARK: - Navigate to MeetingConfirmationVC
    private func navigateToConfirmation(meeting: PTMMeeting) {

        // ── Resolve schoolID with fallback ─────────────────────────────
        var resolvedSchoolID = self.schoolID
        if resolvedSchoolID.isEmpty {
            if let scid = UserManager.shared.selectedKid?.school?.schoolID, !scid.isEmpty {
                resolvedSchoolID = scid
            } else if let scid = UserManager.shared.selectedSchool?.schoolID, !scid.isEmpty {
                resolvedSchoolID = scid
            } else if let scid = UserDefaults.standard.string(forKey: "SCHOOL_ID"), !scid.isEmpty {
                resolvedSchoolID = scid
            } else if let scid = UserDefaults.standard.string(forKey: "SchoolID"), !scid.isEmpty {
                resolvedSchoolID = scid
            } else if let scid = UserDefaults.standard.string(forKey: "school_id"), !scid.isEmpty {
                resolvedSchoolID = scid
            }
        }

        // ── Resolve studentID with fallback ────────────────────────────
        var resolvedStudentID = self.studentID
        if resolvedStudentID.isEmpty {
            if let sid = UserManager.shared.selectedKid?.studentID, !sid.isEmpty {
                resolvedStudentID = sid
            } else if let sid = UserDefaults.standard.string(forKey: "STUDENT_ID"), !sid.isEmpty {
                resolvedStudentID = sid
            }
        }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        guard let vc = storyboard.instantiateViewController(
            withIdentifier: "MeetingConfirmationVC"
        ) as? MeetingConfirmationVC else {
            print("❌ MeetingConfirmationVC not found")
            return
        }

        vc.meetingID = meeting.id
        vc.studentID = resolvedStudentID
        vc.schoolID  = resolvedSchoolID
        vc.meeting   = meeting
        vc.student   = self.ptmData?.student

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("🚀 Navigating to MeetingConfirmationVC")
        print("   meetingID :", meeting.id)
        print("   studentID :", resolvedStudentID.isEmpty ? "⚠️ EMPTY" : resolvedStudentID)
        print("   schoolID  :", resolvedSchoolID.isEmpty  ? "⚠️ EMPTY" : resolvedSchoolID)
        print("   meeting   :", meeting.title)
        print("   student   :", self.ptmData?.student.name ?? "nil")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        if let nav = navigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }

    // MARK: - Spinner Cell
    private func makeSpinnerCell(_ tableView: UITableView) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "SpinnerCell")
        cell.selectionStyle  = .none
        cell.backgroundColor = .clear

        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()

        cell.contentView.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
        ])
        return cell
    }

    // MARK: - Empty Cell
    private func makeEmptyCell(_ tableView: UITableView,
                               message: String) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "EmptyCell")
        cell.selectionStyle  = .none
        cell.backgroundColor = .clear

        let label = UILabel()
        label.text          = message
        label.textColor     = .gray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font          = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false

        cell.contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 24),
            label.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -24)
        ])
        return cell
    }
}
