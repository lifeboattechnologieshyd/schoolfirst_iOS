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

    // MARK: - Public Properties (set before pushing)
    var schoolID: String        = ""
    var studentID: String       = ""
    var studentName: String     = ""
    var selectedMeeting: PTMMeeting?
    var selectedMeetingID: String?

    // MARK: - Private Data
    private var meeting: PTMMeeting?
    private var isLoading: Bool     = true
    private var isOnlineMeeting: Bool = false

    // MARK: - Row Type Enum
    private enum RowType {
        case meetingDetails
        case locationDetails
        case onlineMeetLink
        case purposeAndActions
    }

    // MARK: - Computed Rows based on meeting mode
    private var tableRows: [RowType] {
        if isOnlineMeeting {
            return [.meetingDetails, .onlineMeetLink, .purposeAndActions]
        } else {
            return [.meetingDetails, .locationDetails, .purposeAndActions]
        }
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTopViewShadow()
        setupTableView()

        if let meeting = selectedMeeting {
            self.meeting        = meeting
            self.isOnlineMeeting = meeting.meetingMode.uppercased() == "ONLINE"
            self.isLoading      = false
            tableview.reloadData()
            print("✅ PTMmeetingdetailsVC: Using passed meeting → \(meeting.title)")
            print("   meetingMode   : \(meeting.meetingMode)")
            print("   isOnline      : \(self.isOnlineMeeting)")
            print("   studentName   : \(studentName)")
        } else {
            fetchMeetingDetails()
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

    // MARK: - API Fetch
    private func fetchMeetingDetails() {
        isLoading = true
        tableview.reloadData()

        let schoolId  = schoolID.isEmpty  ? UserManager.shared.resolvedSchoolID  : schoolID
        let studentId = studentID.isEmpty ? UserManager.shared.resolvedStudentID : studentID

        print("📡 PTMDetails fetch | schoolId: \(schoolId) | studentId: \(studentId)")

        guard !schoolId.isEmpty, !studentId.isEmpty else {
            print("❌ PTMDetails: Missing schoolId or studentId")
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
                    print("✅ PTMDetails API success")
                    if response.success, let data = response.data {
                        if let meetingID = self.selectedMeetingID {
                            self.meeting = data.meetings.first(where: { $0.id == meetingID })
                                          ?? data.meetings.first
                        } else {
                            self.meeting = data.meetings.first
                        }
                        // capture student name if not already passed
                        if self.studentName.isEmpty {
                            self.studentName = data.student.name
                        }
                        if let m = self.meeting {
                            self.isOnlineMeeting = m.meetingMode.uppercased() == "ONLINE"
                            print("✅ Meeting loaded: \(m.title)")
                            print("   Mode    : \(m.meetingMode)")
                            print("   isOnline: \(self.isOnlineMeeting)")
                            print("   Student : \(self.studentName)")
                        }
                    }
                case .failure(let error):
                    print("❌ PTMDetails API failed: \(error)")
                    self.meeting = nil
                }
                self.tableview.reloadData()
            }
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
            UINib(nibName: "PTMmeetingdetailsTableViewCell",  bundle: nil),
            forCellReuseIdentifier: "PTMmeetingdetailsTableViewCell"
        )
        tableview.register(
            UINib(nibName: "PTMmeetingdetailsTableViewCell2", bundle: nil),
            forCellReuseIdentifier: "PTMmeetingdetailsTableViewCell2"
        )
        tableview.register(
            UINib(nibName: "PTMonlinemeetTableViewCell3",     bundle: nil),
            forCellReuseIdentifier: "PTMonlinemeetTableViewCell3"
        )
        tableview.register(
            UINib(nibName: "PTMpurposemeetTableViewCell4",    bundle: nil),
            forCellReuseIdentifier: "PTMpurposemeetTableViewCell4"
        )

        tableview.separatorStyle               = .none
        tableview.showsVerticalScrollIndicator = false
    }

    // MARK: - Navigation to MeetingConfirmationVC (UPDATED)
    private func navigateToMeetingConfirmation() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // Try the most likely Storyboard ID first
        if let vc = storyboard.instantiateViewController(
            withIdentifier: "MeetingConfirmationVC"
        ) as? MeetingConfirmationVC {
            configureAndPresent(vc)
            return
        }
        
        // Fallback: Try common variations
        let possibleIDs = ["MeetingConfirmation", "ConfirmationVC", "MeetingConfirmVC"]
        for id in possibleIDs {
            if let vc = storyboard.instantiateViewController(withIdentifier: id) as? MeetingConfirmationVC {
                configureAndPresent(vc)
                return
            }
        }
        
        // Last resort: Instantiate programmatically (if not in storyboard)
        let vc = MeetingConfirmationVC()
        configureAndPresent(vc)
    }

    private func configureAndPresent(_ vc: MeetingConfirmationVC) {
        vc.meeting = meeting
        vc.meetingID = meeting?.id ?? ""
        vc.studentID = studentID.isEmpty ? UserManager.shared.resolvedStudentID : studentID
        vc.schoolID = schoolID.isEmpty ? UserManager.shared.resolvedSchoolID : schoolID
        vc.hidesBottomBarWhenPushed = true

        if let nav = navigationController {
            nav.setNavigationBarHidden(true, animated: false)
            nav.pushViewController(vc, animated: true)
        } else {
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }

    // MARK: - Meeting Response Handlers (UNCHANGED)
    func handleConfirmMeeting() {
        guard let meetingID = meeting?.id else { return }
        print("✅ Confirm tapped | meetingID: \(meetingID)")
        postMeetingResponse(status: "ATTENDING")
    }

    func handleDeclineMeeting() {
        guard let meetingID = meeting?.id else { return }
        print("❌ Decline tapped | meetingID: \(meetingID)")
        postMeetingResponse(status: "NOT_ATTENDING")
    }

    private func postMeetingResponse(status: String) {
        let schoolId  = schoolID.isEmpty  ? UserManager.shared.resolvedSchoolID  : schoolID
        let studentId = studentID.isEmpty ? UserManager.shared.resolvedStudentID : studentID

        guard let meetingID = meeting?.id,
              !schoolId.isEmpty,
              !studentId.isEmpty else {
            print("❌ postMeetingResponse: missing data")
            return
        }

        print("📡 PTM Response | status: \(status) | meetingID: \(meetingID)")

        let loadingAlert = UIAlertController(
            title: nil,
            message: "Updating...",
            preferredStyle: .alert
        )
        let spinner = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        spinner.hidesWhenStopped = true
        spinner.style            = .medium
        spinner.startAnimating()
        loadingAlert.view.addSubview(spinner)
        present(loadingAlert, animated: true)

        NetworkManager.shared.request(
            urlString: "\(API.PTM_MEETINGS)/\(meetingID)/respond",
            method: .POST,
            requiresAuth: true,
            parameters: [
                "student_id":      studentId,
                "response_status": status
            ],
            headers: ["X-School-Id": schoolId]
        ) { [weak self] (result: Result<APIResponse<PTMMeeting>, NetworkError>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                loadingAlert.dismiss(animated: true) {
                    switch result {
                    case .success(let response):
                        if response.success {
                            let msg = status == "ATTENDING"
                                ? "You have confirmed your attendance."
                                : "You have declined this meeting."
                            self.showAlert(title: "Updated", message: msg) {
                                self.navigationController?.popViewController(animated: true)
                            }
                        } else {
                            self.showAlert(title: "Error", message: "Failed to update. Please try again.")
                        }
                    case .failure(let error):
                        print("❌ PTM response API failed: \(error)")
                        self.showAlert(title: "Error", message: "Network error. Please try again.")
                    }
                }
            }
        }
    }

    private func showAlert(
        title: String,
        message: String,
        completion: (() -> Void)? = nil
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
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
        if isLoading { return 3 }
        return tableRows.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        // ── Loading placeholder ───────────────────────────────────────────
        if isLoading {
            let cell = UITableViewCell()
            cell.backgroundColor = UIColor.systemGray6
            cell.selectionStyle  = .none
            return cell
        }

        guard indexPath.row < tableRows.count else {
            return UITableViewCell()
        }

        switch tableRows[indexPath.row] {

        // ── Row: Meeting Details ──────────────────────────────────────────
        case .meetingDetails:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "PTMmeetingdetailsTableViewCell",
                for: indexPath
            ) as! PTMmeetingdetailsTableViewCell
            cell.selectionStyle = .none
            cell.configure(with: meeting, studentName: studentName)
            return cell

        // ── Row: Location (Offline only) ──────────────────────────────────
        case .locationDetails:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "PTMmeetingdetailsTableViewCell2",
                for: indexPath
            ) as! PTMmeetingdetailsTableViewCell2
            cell.selectionStyle = .none
            cell.configure(with: meeting)
            return cell

        // ── Row: Online Meet Link (Online only) ───────────────────────────
        case .onlineMeetLink:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "PTMonlinemeetTableViewCell3",
                for: indexPath
            ) as! PTMonlinemeetTableViewCell3
            cell.selectionStyle = .none
            cell.configure(with: meeting)
            return cell

        // ── Row: Purpose & Actions ────────────────────────────────────────
        case .purposeAndActions:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "PTMpurposemeetTableViewCell4",
                for: indexPath
            ) as! PTMpurposemeetTableViewCell4
            cell.selectionStyle = .none
            cell.configure(with: meeting)
            // 🔹 UPDATED: Force-enable Confirm button for navigation (if needed)
            cell.ConfirmButton.isEnabled = true
            cell.onConfirmTap = { [weak self] in
                self?.navigateToMeetingConfirmation()
            }
            cell.onDeclineTap = { [weak self] in
                self?.handleDeclineMeeting()
            }
            return cell
        }
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        if isLoading {
            switch indexPath.row {
            case 0:  return 330
            case 1:  return 160
            case 2:  return 400
            default: return UITableView.automaticDimension
            }
        }

        guard indexPath.row < tableRows.count else {
            return UITableView.automaticDimension
        }

        switch tableRows[indexPath.row] {
        case .meetingDetails:    return 330
        case .locationDetails:   return 160
        case .onlineMeetLink:    return 210
        case .purposeAndActions: return 400
        }
    }
}
