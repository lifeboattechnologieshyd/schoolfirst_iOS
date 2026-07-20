//
//  MeetingConfirmationVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 18/06/26.
//

import UIKit

class MeetingConfirmationVC: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var AddtocalendarButton: UIButton!
    @IBOutlet weak var Meetingtime: UILabel!
    @IBOutlet weak var MeetingdateLbl: UILabel!
    @IBOutlet weak var MeetingtitleLbl: UILabel!
    @IBOutlet weak var BacktohomeButton: UIButton!

    // MARK: - Received from PTMmeetingdetailsVC
    var meetingID : String = ""
    var studentID : String = ""
    var schoolID  : String = ""
    var meeting   : PTMMeeting?
    var student   : PTMStudent?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // ── Resolve IDs from DBManager / UserManager / UserDefaults ─────
        resolveIDs()

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📌 MeetingConfirmationVC — viewDidLoad")
        print("   meetingID :", meetingID.isEmpty ? "⚠️ EMPTY" : meetingID)
        print("   studentID :", studentID.isEmpty ? "⚠️ EMPTY" : studentID)
        print("   schoolID  :", schoolID.isEmpty  ? "⚠️ EMPTY" : schoolID)
        print("   meeting   :", meeting?.title    ?? "nil")
        print("   student   :", student?.name     ?? "nil")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        BacktohomeButton.addTarget(
            self,
            action: #selector(backToHomeTapped),
            for: .touchUpInside
        )

        AddtocalendarButton.addTarget(
            self,
            action: #selector(addToCalendarTapped),
            for: .touchUpInside
        )

        // Populate UI with meeting object if already passed
        if let meeting = meeting {
            populateUI(with: meeting)
        }

        // Fetch latest details from API
        fetchPTMMeetings()
    }

    // MARK: - Resolve IDs (Fallback Chain)
    private func resolveIDs() {

        // ── studentID resolution ─────────────────────────────
        if studentID.isEmpty {
            if let sid = UserManager.shared.selectedKid?.studentID, !sid.isEmpty {
                studentID = sid
                print("🔄 studentID from UserManager.selectedKid:", studentID)
            } else if let sid = UserDefaults.standard.string(forKey: "STUDENT_ID"), !sid.isEmpty {
                studentID = sid
                print("🔄 studentID from UserDefaults[STUDENT_ID]:", studentID)
            } else {
                studentID = UserManager.shared.resolvedStudentID
                print("🔄 studentID from resolvedStudentID:", studentID)
            }
        }

        // ── schoolID resolution ──────────────────────────────
        if schoolID.isEmpty {
            if let scid = UserManager.shared.selectedKid?.school?.schoolID, !scid.isEmpty {
                schoolID = scid
                print("🔄 schoolID from selectedKid.school:", schoolID)
            } else if let scid = UserManager.shared.selectedSchool?.schoolID, !scid.isEmpty {
                schoolID = scid
                print("🔄 schoolID from selectedSchool:", schoolID)
            } else if let scid = UserDefaults.standard.string(forKey: "SCHOOL_ID"), !scid.isEmpty {
                schoolID = scid
                print("🔄 schoolID from UserDefaults[SCHOOL_ID]:", schoolID)
            } else if let scid = UserDefaults.standard.string(forKey: "SchoolID"), !scid.isEmpty {
                schoolID = scid
                print("🔄 schoolID from UserDefaults[SchoolID]:", schoolID)
            } else if let scid = UserDefaults.standard.string(forKey: "school_id"), !scid.isEmpty {
                schoolID = scid
                print("🔄 schoolID from UserDefaults[school_id]:", schoolID)
            } else {
                schoolID = UserManager.shared.resolvedSchoolID
                print("🔄 schoolID from resolvedSchoolID:", schoolID)
            }
        }
    }

    // MARK: - API Call: PTM Meetings
    private func fetchPTMMeetings() {

        guard !studentID.isEmpty, !schoolID.isEmpty else {
            print("⚠️ studentID or schoolID is empty — skipping API call")
            return
        }

        print("🌐 Fetching PTM Meetings:", API.PTM_MEETINGS)
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

                switch result {

                case .success(let response):

                    print("✅ PTM Meetings — success:", response.success)
                    print("   description :", response.description)

                    guard let data = response.data else {
                        print("⚠️ No data in PTM response")
                        return
                    }

                    self.student = data.student
                    print("👨‍🎓 Student:", data.student.name)
                    print("📅 Meetings count:", data.meetings.count)

                    // Prefer the meeting matching self.meetingID; else use first
                    let matched: PTMMeeting?

                    if !self.meetingID.isEmpty {
                        matched = data.meetings.first(where: { $0.id == self.meetingID })
                                  ?? data.meetings.first
                    } else {
                        matched = data.meetings.first
                    }

                    if let meeting = matched {
                        self.meeting = meeting
                        self.populateUI(with: meeting)
                    } else {
                        print("⚠️ No meeting found in response")
                    }

                case .failure(let error):
                    print("❌ PTM Meetings failed:", error)
                }
            }
        }
    }

    // MARK: - Populate UI
    private func populateUI(with meeting: PTMMeeting) {

        print("🟢 Populating UI with meeting:", meeting.title)

        MeetingtitleLbl.text = meeting.title.isEmpty ? "Parent-Teacher Meeting" : meeting.title
        MeetingdateLbl.text  = meeting.formattedDate
        Meetingtime.text     = meeting.formattedTimeRange
    }

    // MARK: - Add to Calendar
    @objc private func addToCalendarTapped() {
        print("📅 Add to Calendar tapped")
        // TODO: Integrate EventKit if needed
    }

    // MARK: - Back to Home
    @objc private func backToHomeTapped() {

        let storyboard = UIStoryboard(
            name: "Main",
            bundle: nil
        )

        if let homeVC = storyboard.instantiateViewController(
            withIdentifier: "Homescreen"
        ) as? Homescreen {

            if let nav = navigationController {

                nav.setNavigationBarHidden(
                    true,
                    animated: false
                )

                nav.pushViewController(
                    homeVC,
                    animated: true
                )

            } else {

                homeVC.modalPresentationStyle = .fullScreen

                present(
                    homeVC,
                    animated: true
                )
            }
        }
    }
}
