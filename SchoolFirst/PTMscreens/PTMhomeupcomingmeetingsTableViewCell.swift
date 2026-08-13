//
//  PTMhomeupcomingmeetingsTableViewCell.swift
//  SchoolFirst
//

import UIKit

class PTMhomeupcomingmeetingsTableViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var MeetingtitleLbl: UILabel!
    @IBOutlet weak var NamefirstletterLbl: UILabel!
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
        MeetingtitleLbl?.text    = nil
        Studentgrade?.text       = nil
        StudentnameLBl?.text     = nil
        NamefirstletterLbl?.text = nil
        Meetinglocation?.text    = nil
        Meetingdate?.text        = nil
        meeting                  = nil
        studentName              = ""
        parentVC                 = nil
    }

    // MARK: - Verify Outlets (debug helper)
    private func verifyOutlets() {
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("🔍 PTMhomeupcomingmeetingsTableViewCell — verifyOutlets()")
        print("   MeetingtitleLbl    :", MeetingtitleLbl     == nil ? "❌ NOT CONNECTED" : "✅ connected")
        print("   StudentnameLBl     :", StudentnameLBl      == nil ? "❌ NOT CONNECTED" : "✅ connected")
        print("   NamefirstletterLbl :", NamefirstletterLbl  == nil ? "❌ NOT CONNECTED" : "✅ connected")
        print("   Studentgrade       :", Studentgrade        == nil ? "❌ NOT CONNECTED" : "✅ connected")
        print("   Meetinglocation    :", Meetinglocation     == nil ? "❌ NOT CONNECTED" : "✅ connected")
        print("   Meetingdate        :", Meetingdate         == nil ? "❌ NOT CONNECTED" : "✅ connected")
        print("   ViewdetailsButton  :", ViewdetailsButton   == nil ? "❌ NOT CONNECTED" : "✅ connected")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    }

    // MARK: - Configure with meeting
    func configure(with meeting: PTMMeeting, studentName: String, parentVC: UIViewController) {
        self.meeting     = meeting
        self.studentName = studentName
        self.parentVC    = parentVC

        // ── DEBUG: verify what's being set ─────────────────────────────
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📋 PTMhomeupcomingmeetingsTableViewCell configure()")
        print("   studentName passed :", studentName)
        print("   meeting title      :", meeting.title)
        print("   meeting grade      :", meeting.grade.name)
        print("   meeting section    :", meeting.section.name)
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        // ── Meeting Title ────────────────────────────────────────────────
        let displayTitle = meeting.title.isEmpty ? "Parent Teacher Meeting" : meeting.title
        MeetingtitleLbl.text            = displayTitle
        MeetingtitleLbl.isHidden        = false
        MeetingtitleLbl.alpha           = 1.0
        MeetingtitleLbl.textColor       = .black
        MeetingtitleLbl.numberOfLines   = 2
        MeetingtitleLbl.lineBreakMode   = .byTruncatingTail
        MeetingtitleLbl.backgroundColor = .clear

        print("✅ MeetingtitleLbl.text set to:", displayTitle)

        // ── Student name ─────────────────────────────────────────────────
        let displayName = studentName.isEmpty ? "Student" : studentName
        StudentnameLBl.text            = displayName
        StudentnameLBl.isHidden        = false
        StudentnameLBl.alpha           = 1.0
        StudentnameLBl.textColor       = .black
        StudentnameLBl.numberOfLines   = 1
        StudentnameLBl.lineBreakMode   = .byTruncatingTail
        StudentnameLBl.backgroundColor = .clear

        print("✅ StudentnameLBl.text set to:", StudentnameLBl.text ?? "nil")

        // ── First Letter of Student Name ─────────────────────────────────
        let firstLetter = getFirstLetter(from: displayName)
        NamefirstletterLbl.text          = firstLetter
        NamefirstletterLbl.isHidden      = false
        NamefirstletterLbl.alpha         = 1.0
        NamefirstletterLbl.textAlignment = .center

        print("✅ NamefirstletterLbl.text set to:", firstLetter)

        // ── Grade & Section ──────────────────────────────────────────────
        Studentgrade.text            = "\(meeting.grade.name) - \(meeting.section.name)"
        Studentgrade.isHidden        = false
        Studentgrade.alpha           = 1.0
        Studentgrade.textColor       = .darkGray
        Studentgrade.backgroundColor = .clear

        // ── Location ─────────────────────────────────────────────────────
        if meeting.meetingMode.uppercased() == "OFFLINE" {
            Meetinglocation.text = (meeting.location?.isEmpty == false) ? meeting.location : "School"
        } else {
            Meetinglocation.text = (meeting.meetingLink?.isEmpty == false) ? meeting.meetingLink : "Online"
        }
        Meetinglocation.isHidden        = false
        Meetinglocation.textColor       = .black
        Meetinglocation.backgroundColor = .clear

        // ── Date & Time ──────────────────────────────────────────────────
        Meetingdate.text            = "\(meeting.formattedDate) | \(meeting.formattedTimeRange)"
        Meetingdate.isHidden        = false
        Meetingdate.textColor       = .black
        Meetingdate.backgroundColor = .clear

        // ── Force layout update ──────────────────────────────────────────
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()

        // ── DEBUG: verify frames ────────────────────────────────────────
        print("🟢 MeetingtitleLbl frame :", MeetingtitleLbl.frame)
        print("🟢 MeetingtitleLbl text  :", MeetingtitleLbl.text ?? "nil")
        print("🟢 StudentnameLBl frame  :", StudentnameLBl.frame)
        print("🟢 StudentnameLBl text   :", StudentnameLBl.text ?? "nil")
    }

    // MARK: - Helper: Get First Letter (uppercased)
    private func getFirstLetter(from name: String) -> String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let first = trimmed.first else { return "?" }
        return String(first).uppercased()
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

        if let ptmHomeVC = parentVC as? PTMhomeVC {
            ptmHomeVC.navigateToPTMDetails(meeting: self.meeting)
            return
        }

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
