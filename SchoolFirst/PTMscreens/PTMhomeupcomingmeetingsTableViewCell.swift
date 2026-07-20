//
//  PTMhomeupcomingmeetingsTableViewCell.swift
//  SchoolFirst
//

import UIKit

class PTMhomeupcomingmeetingsTableViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var Studentgrade: UILabel!
    @IBOutlet weak var StudentnameLBl: UILabel!
    @IBOutlet weak var Meetinglocation: UILabel!
    @IBOutlet weak var Meetingdate: UILabel!
    @IBOutlet weak var ViewdetailsButton: UIButton!

    // MARK: - Properties
    private var meeting: PTMMeeting?
    private var studentName: String = ""
    private weak var parentVC: UIViewController?

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        verifyOutlets()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        Studentgrade.text    = nil
        StudentnameLBl.text  = nil
        Meetinglocation.text = nil
        Meetingdate.text     = nil
        meeting              = nil
        studentName          = ""
        parentVC             = nil
    }

    // MARK: - Verify Outlets (debug helper)
    private func verifyOutlets() {
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("🔍 PTMhomeupcomingmeetingsTableViewCell — verifyOutlets()")
        print("   StudentnameLBl :", StudentnameLBl  == nil ? "❌ NOT CONNECTED" : "✅ connected")
        print("   Studentgrade   :", Studentgrade    == nil ? "❌ NOT CONNECTED" : "✅ connected")
        print("   Meetinglocation:", Meetinglocation == nil ? "❌ NOT CONNECTED" : "✅ connected")
        print("   Meetingdate    :", Meetingdate     == nil ? "❌ NOT CONNECTED" : "✅ connected")
        print("   ViewdetailsButton:", ViewdetailsButton == nil ? "❌ NOT CONNECTED" : "✅ connected")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    }

    // MARK: - Configure with meeting
    func configure(with meeting: PTMMeeting, studentName: String, parentVC: UIViewController) {
        self.meeting     = meeting
        self.studentName = studentName
        self.parentVC    = parentVC

        // ── Student name ─────────────────────────────────────────────────
        StudentnameLBl.text          = studentName
        StudentnameLBl.isHidden      = false
        StudentnameLBl.alpha         = 1.0
        StudentnameLBl.textColor     = .black        // ← force visible color
        StudentnameLBl.numberOfLines = 1
        StudentnameLBl.lineBreakMode = .byTruncatingTail

        // ── Grade & Section ──────────────────────────────────────────────
        Studentgrade.text     = "\(meeting.grade.name) - \(meeting.section.name)"
        Studentgrade.isHidden = false
        Studentgrade.alpha    = 1.0

        // ── Location ─────────────────────────────────────────────────────
        if meeting.meetingMode == "OFFLINE" {
            Meetinglocation.text = meeting.location ?? "School"
        } else {
            Meetinglocation.text = meeting.meetingLink ?? "Online"
        }
        Meetinglocation.isHidden = false

        // ── Date & Time ──────────────────────────────────────────────────
        Meetingdate.text     = "\(meeting.formattedDate) | \(meeting.formattedTimeRange)"
        Meetingdate.isHidden = false

        // ── Force layout update ──────────────────────────────────────────
        setNeedsLayout()
        layoutIfNeeded()
    }

    // MARK: - Configure with parentVC only (skeleton/loading state)
    func configureParent(parentVC: UIViewController) {
        self.parentVC = parentVC
        print("✅ Cell parentVC set (skeleton): \(parentVC)")
    }

    // MARK: - Button Action
    @IBAction func ViewdetailsButtonTapped(_ sender: UIButton) {
        print("🔘 ViewDetails button tapped")
        print("🔍 parentVC  :", String(describing: parentVC))
        print("🔍 meeting   :", meeting?.title ?? "nil")
        print("🔍 meetingID :", meeting?.id    ?? "nil")

        // ── Use PTMhomeVC navigate method if available ───────────────────
        if let ptmHomeVC = parentVC as? PTMhomeVC {
            ptmHomeVC.navigateToPTMDetails(meeting: self.meeting)
            return
        }

        // ── Fallback: manual navigation ──────────────────────────────────
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        guard let detailsVC = storyboard.instantiateViewController(
            withIdentifier: "PTMmeetingdetailsVC"
        ) as? PTMmeetingdetailsVC else {
            print("❌ PTMmeetingdetailsVC not found")
            return
        }

        detailsVC.selectedMeeting   = self.meeting
        detailsVC.selectedMeetingID = self.meeting?.id

        if let nav = parentVC?.navigationController {
            nav.pushViewController(detailsVC, animated: true)
        } else if let parent = parentVC {
            detailsVC.modalPresentationStyle = .fullScreen
            parent.present(detailsVC, animated: true)
        } else {
            print("❌ parentVC is nil — cannot navigate")
        }
    }
}
