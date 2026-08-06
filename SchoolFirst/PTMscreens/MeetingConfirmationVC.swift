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

    // Track if API was already posted (avoid double-posting)
    private var hasPostedResponse: Bool = false

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

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

        // Populate UI immediately with passed meeting object
        if let meeting = meeting {
            populateUI(with: meeting)
        }

        // POST ATTENDING response to API
        postAttendingResponse()

        // Fetch latest meeting details from PTM API
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

        // ── meetingID resolution ─────────────────────────────
        if meetingID.isEmpty, let mid = meeting?.id, !mid.isEmpty {
            meetingID = mid
            print("🔄 meetingID from meeting.id:", meetingID)
        }
    }

    // MARK: - POST ATTENDING Response
    // MARK: - POST ATTENDING Response
    // MARK: - POST ATTENDING Response
    // MARK: - POST ATTENDING Response
    private func postAttendingResponse() {
        guard !hasPostedResponse else {
            print("ℹ️ ATTENDING already posted — skipping")
            return
        }
        guard !meetingID.isEmpty, !studentID.isEmpty else {
            print("⚠️ postAttendingResponse: meetingID or studentID empty — skipping")
            return
        }

        hasPostedResponse = true

        // ✅ FIX: No query param — student_id goes in JSON body
        let baseURL   = API.BASE_URL.hasSuffix("/")
                        ? String(API.BASE_URL.dropLast())
                        : API.BASE_URL
        let urlString = "\(baseURL)/ptm/parent-response/\(meetingID)"

        print("📡 POST ATTENDING Response")
        print("   URL       : \(urlString)")
        print("   studentID : \(studentID)")
        print("   schoolID  : \(schoolID)")

        // ✅ FIX: student_id IN body params
        let bodyParams: [String: Any] = [
            "student_id":      studentID,
            "response_status": PTMResponseStatus.attending.rawValue
        ]

        print("   bodyParams: \(bodyParams)")

        NetworkManager.shared.request(
            urlString: urlString,
            method: .POST,
            requiresAuth: true,
            parameters: bodyParams,           // ← all in body
            headers: ["X-School-Id": schoolID]
        ) { (result: Result<APIResponse<PTMParentResponseData>, NetworkError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("✅ ATTENDING posted successfully")
                    print("   status      : \(response.data?.responseStatus      ?? "nil")")
                    print("   respondedAt : \(response.data?.formattedRespondedAt ?? "nil")")
                case .failure(let error):
                    print("❌ ATTENDING post failed: \(error)")
                }
            }
        }
    }
    // MARK: - API Call: PTM Meetings (fetch fresh data)
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
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        if let homeVC = storyboard.instantiateViewController(
            withIdentifier: "Homescreen"
        ) as? Homescreen {
            if let nav = navigationController {
                nav.setNavigationBarHidden(true, animated: false)
                nav.pushViewController(homeVC, animated: true)
            } else {
                homeVC.modalPresentationStyle = .fullScreen
                present(homeVC, animated: true)
            }
        } else {
            navigationController?.popToRootViewController(animated: true)
        }
    }
}
