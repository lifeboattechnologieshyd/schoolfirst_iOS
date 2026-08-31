//
//  DeclinedsuccessVC.swift
//  SchoolFirst
//

import UIKit

class DeclinedsuccessVC: UIViewController {

    // MARK: - Outlets (connect in Storyboard)
    @IBOutlet weak var BacktohomeButton: UIButton!
    @IBOutlet weak var MeetingtitleLbl: UILabel!
    @IBOutlet weak var MeetingdateLbl: UILabel!
    @IBOutlet weak var MeetingtimeLbl: UILabel!
    @IBOutlet weak var RemarksLbl: UILabel!
    @IBOutlet weak var StatusLbl: UILabel!
    @IBOutlet weak var RespondedAtLbl: UILabel!
    @IBOutlet weak var BackButton: UIButton!
    
    // MARK: - Public Properties (set from MeetingdeclinepopupVC)
    var meeting         : PTMMeeting?
    var meetingID       : String = ""
    var studentID       : String = ""
    var schoolID        : String = ""
    var responseData    : PTMParentResponseData?
    var selectedRemarks : String = ""

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        populateUI()

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📌 DeclinedsuccessVC — viewDidLoad")
        print("   meetingID      : \(meetingID.isEmpty ? "⚠️ EMPTY" : meetingID)")
        print("   studentID      : \(studentID.isEmpty ? "⚠️ EMPTY" : studentID)")
        print("   selectedRemarks: \(selectedRemarks)")
        print("   responseStatus : \(responseData?.responseStatus ?? "nil")")
        print("   respondedAt    : \(responseData?.formattedRespondedAt ?? "nil")")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    }

    // MARK: - Setup UI
    private func setupUI() {
        BacktohomeButton?.layer.cornerRadius = 8
        BacktohomeButton?.clipsToBounds      = true

        BacktohomeButton?.addTarget(
            self,
            action: #selector(backToHomeTapped),
            for: .touchUpInside
        )

        // ── Programmatically register action for BackButton to ensure it works instantly ──
        BackButton?.addTarget(
            self,
            action: #selector(backButtonTappedAction),
            for: .touchUpInside
        )
    }

    // MARK: - Populate UI
    private func populateUI() {

        // ── Meeting Info ──────────────────────────────────────────────────
        if let meeting = meeting {
            MeetingtitleLbl?.text = meeting.title.isEmpty
                ? "Parent-Teacher Meeting"
                : meeting.title
            MeetingdateLbl?.text  = meeting.formattedDate
            MeetingtimeLbl?.text  = meeting.formattedTimeRange
        } else {
            MeetingtitleLbl?.text = "Parent-Teacher Meeting"
            MeetingdateLbl?.text  = "--"
            MeetingtimeLbl?.text  = "--"
        }

        // ── Response Info ─────────────────────────────────────────────────
        if let response = responseData {
            StatusLbl?.text      = response.statusDisplayText  // "Not Attending"
            RespondedAtLbl?.text = response.formattedRespondedAt
        } else {
            StatusLbl?.text      = "Not Attending"
            RespondedAtLbl?.text = "--"
        }

        // ── Remarks ───────────────────────────────────────────────────────
        RemarksLbl?.text = selectedRemarks.isEmpty
            ? (responseData?.remarks.isEmpty == false ? responseData?.remarks : "No remarks provided")
            : selectedRemarks

        print("✅ DeclinedsuccessVC populated:")
        print("   title       : \(MeetingtitleLbl?.text ?? "nil")")
        print("   date        : \(MeetingdateLbl?.text  ?? "nil")")
        print("   time        : \(MeetingtimeLbl?.text  ?? "nil")")
        print("   status      : \(StatusLbl?.text       ?? "nil")")
        print("   respondedAt : \(RespondedAtLbl?.text  ?? "nil")")
        print("   remarks     : \(RemarksLbl?.text      ?? "nil")")
    }

    // MARK: - Navigation Actions

    @objc private func backButtonTappedAction() {
        if let nav = navigationController {
            // Find the existing PTMhomeVC in the navigation controller's stack and pop directly to it
            for vc in nav.viewControllers {
                if vc is PTMhomeVC {
                    print("🔄 Popping back to existing PTMhomeVC")
                    nav.popToViewController(vc, animated: true)
                    return
                }
            }
            // Fallback: If PTMhomeVC is not found in the stack, pop one step back
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    @objc private func backToHomeTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        if let homeVC = storyboard.instantiateViewController(
            withIdentifier: "Homescreen"
        ) as? Homescreen {
            if let nav = navigationController {
                nav.setNavigationBarHidden(true, animated: false)
                // Pop to root or push to home
                nav.pushViewController(homeVC, animated: true)
            } else {
                homeVC.modalPresentationStyle = .fullScreen
                present(homeVC, animated: true)
            }
        } else {
            // Fallback: pop to root
            navigationController?.popToRootViewController(animated: true)
        }
    }

    // MARK: - IBActions (connected via Storyboard)

    @IBAction func BackButtonTapped(_ sender: UIButton) {
        backButtonTappedAction()
    }

    @IBAction func BacktohomeButtonTapped(_ sender: UIButton) {
        backToHomeTapped()
    }
}
