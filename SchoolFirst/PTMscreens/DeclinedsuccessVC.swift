//
//  DeclinedsuccessVC.swift
//  SchoolFirst
//

import UIKit

class DeclinedsuccessVC: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var BacktohomeButton: UIButton!
    @IBOutlet weak var MeetingtitleLbl: UILabel!
    @IBOutlet weak var MeetingdateLbl: UILabel!
    @IBOutlet weak var MeetingtimeLbl: UILabel!
    @IBOutlet weak var RemarksLbl: UILabel!
    @IBOutlet weak var StatusLbl: UILabel!
    @IBOutlet weak var RespondedAtLbl: UILabel!
    @IBOutlet weak var BackButton: UIButton!
    
    // MARK: - Public Properties
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

        BackButton?.addTarget(
            self,
            action: #selector(backButtonTappedAction),
            for: .touchUpInside
        )
    }

    // MARK: - Populate UI
    private func populateUI() {

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

        if let response = responseData {
            StatusLbl?.text      = response.statusDisplayText
            RespondedAtLbl?.text = response.formattedRespondedAt
        } else {
            StatusLbl?.text      = "Not Attending"
            RespondedAtLbl?.text = "--"
        }

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
            for vc in nav.viewControllers {
                if vc is PTMhomeVC {
                    print("🔄 Popping back to existing PTMhomeVC")
                    nav.popToViewController(vc, animated: true)
                    return
                }
            }
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

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

    // MARK: - IBActions
    @IBAction func BackButtonTapped(_ sender: UIButton) {
        backButtonTappedAction()
    }

    @IBAction func BacktohomeButtonTapped(_ sender: UIButton) {
        backToHomeTapped()
    }
}
