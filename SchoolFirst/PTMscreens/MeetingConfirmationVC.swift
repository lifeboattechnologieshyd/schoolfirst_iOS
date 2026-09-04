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

    // ✅ NEW: Callback to inform parent about API result
    var onResponsePosted: ((_ status: String) -> Void)?

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

        if let meeting = meeting {
            populateUI(with: meeting)
        }

        postAttendingResponse()
    }

    // MARK: - Resolve IDs (Fallback Chain)
    private func resolveIDs() {

        if studentID.isEmpty {
            if let sid = UserManager.shared.selectedKid?.studentID, !sid.isEmpty {
                studentID = sid
            } else if let sid = UserDefaults.standard.string(forKey: "STUDENT_ID"), !sid.isEmpty {
                studentID = sid
            } else {
                studentID = UserManager.shared.resolvedStudentID
            }
        }

        if schoolID.isEmpty {
            if let scid = UserManager.shared.selectedKid?.school?.schoolID, !scid.isEmpty {
                schoolID = scid
            } else if let scid = UserManager.shared.selectedSchool?.schoolID, !scid.isEmpty {
                schoolID = scid
            } else if let scid = UserDefaults.standard.string(forKey: "SCHOOL_ID"), !scid.isEmpty {
                schoolID = scid
            } else if let scid = UserDefaults.standard.string(forKey: "SchoolID"), !scid.isEmpty {
                schoolID = scid
            } else if let scid = UserDefaults.standard.string(forKey: "school_id"), !scid.isEmpty {
                schoolID = scid
            } else {
                schoolID = UserManager.shared.resolvedSchoolID
            }
        }

        if meetingID.isEmpty, let mid = meeting?.id, !mid.isEmpty {
            meetingID = mid
        }
    }

    // MARK: - POST ATTENDING Response using raw URLRequest
    private func postAttendingResponse() {
        guard !hasPostedResponse else { return }
        guard !meetingID.isEmpty, !studentID.isEmpty else { return }

        hasPostedResponse = true

        let baseURL = API.BASE_URL.hasSuffix("/")
                        ? String(API.BASE_URL.dropLast())
                        : API.BASE_URL

        let urlString = "\(baseURL)/ptm/parent-response/\(meetingID)?student_id=\(studentID)"

        print("📡 POST ATTENDING Response (raw URLRequest)")
        print("   URL       : \(urlString)")

        let bodyDict: [String: Any] = [
            "student_id":      studentID,
            "response_status": PTMResponseStatus.attending.rawValue
        ]

        guard let jsonData = try? JSONSerialization.data(
            withJSONObject: bodyDict,
            options: []
        ) else {
            print("❌ Failed to serialize JSON body")
            hasPostedResponse = false
            return
        }

        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(schoolID, forHTTPHeaderField: "X-School-Id")
        request.httpBody = jsonData
        request.timeoutInterval = 60

        // Add auth token
        let possibleKeys = ["ACCESSTOKEN", "accessToken", "access_token", "token"]
        for key in possibleKeys {
            if let storedToken = UserDefaults.standard.string(forKey: key) {
                let cleaned = storedToken.trimmingCharacters(in: .whitespacesAndNewlines)
                if !cleaned.isEmpty {
                    let authValue = cleaned.lowercased().hasPrefix("bearer ") || cleaned.lowercased().hasPrefix("token ")
                        ? cleaned
                        : "Bearer \(cleaned)"
                    request.setValue(authValue, forHTTPHeaderField: "Authorization")
                    break
                }
            }
        }

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }

            DispatchQueue.main.async {
                if let error = error {
                    print("❌ ATTENDING post failed: \(error.localizedDescription)")
                    self.hasPostedResponse = false
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else { return }

                let responseString = String(data: data ?? Data(), encoding: .utf8) ?? ""
                print("📥 ATTENDING Response status: \(httpResponse.statusCode)")
                print("📥 ATTENDING Response body: \(responseString)")

                guard let data = data else { return }

                do {
                    let decoded = try JSONDecoder().decode(
                        APIResponse<PTMParentResponseData>.self,
                        from: data
                    )

                    if decoded.success {
                        print("✅ ATTENDING posted successfully")
                        print("   status      : \(decoded.data?.responseStatus ?? "nil")")
                        
                        // ✅ Trigger callback with the response status
                        self.onResponsePosted?(decoded.data?.responseStatus ?? "ATTENDING")
                    } else {
                        print("⚠️ ATTENDING API returned success=false: \(decoded.description)")
                    }
                } catch {
                    print("❌ ATTENDING decode failed: \(error)")
                    if (200...299).contains(httpResponse.statusCode) {
                        // ✅ Even if decode fails, treat as success
                        self.onResponsePosted?("ATTENDING")
                    }
                }
            }
        }.resume()
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
    }

    // MARK: - Back to Home
    @objc private func backToHomeTapped() {
        if let nav = navigationController {
            for vc in nav.viewControllers {
                if vc is PTMhomeVC {
                    print("🔄 Popping back to existing PTMhomeVC")
                    nav.popToViewController(vc, animated: true)
                    return
                }
            }
            nav.popToRootViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}
