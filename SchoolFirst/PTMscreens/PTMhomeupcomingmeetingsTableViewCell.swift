//
//  PTMhomeupcomingmeetingsTableViewCell.swift
//  SchoolFirst
//

import UIKit

class PTMhomeupcomingmeetingsTableViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var MeetingstatusLbl: UILabel!
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
        setupStatusLabelStyle()
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
        MeetingstatusLbl?.text   = nil
        MeetingstatusLbl?.isHidden = true
        meeting                  = nil
        studentName              = ""
        parentVC                 = nil
    }

    // MARK: - Setup Label Style
    private func setupStatusLabelStyle() {
        MeetingstatusLbl?.layer.cornerRadius = 6
        MeetingstatusLbl?.clipsToBounds = true
        MeetingstatusLbl?.textAlignment = .center
        MeetingstatusLbl?.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
    }

    // MARK: - Verify Outlets (debug helper)
    private func verifyOutlets() {
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("🔍 PTMhomeupcomingmeetingsTableViewCell — verifyOutlets()")
        print("   MeetingstatusLbl   :", MeetingstatusLbl    == nil ? "❌ NOT CONNECTED" : "✅ connected")
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
        print("   meeting status     :", meeting.status)
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

        // ── Configure Status Badge (MeetingstatusLbl) ───────────────────
        configureStatusBadge(meeting: meeting)

        // ── Force layout update ──────────────────────────────────────────
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()
    }

    // MARK: - Configure Status Badge
    private func configureStatusBadge(meeting: PTMMeeting) {
        guard MeetingstatusLbl != nil else { return }
        
        MeetingstatusLbl.isHidden = false
        
        // 1) First check Parent RSVP response inside the meeting
        if let parentResponse = meeting.response {
            let rStatus = parentResponse.responseStatus.lowercased()
            
            if rStatus.contains("attending") || rStatus.contains("accepted") || rStatus == "attending" {
                MeetingstatusLbl.text = "  Attending  "
                MeetingstatusLbl.textColor = UIColor(red: 46/255, green: 117/255, blue: 89/255, alpha: 1.0) // Green
                MeetingstatusLbl.backgroundColor = UIColor(red: 235/255, green: 247/255, blue: 242/255, alpha: 1.0)
            } else if rStatus.contains("declined") || rStatus.contains("not") || rStatus == "not_attending" {
                MeetingstatusLbl.text = "  Declined  "
                MeetingstatusLbl.textColor = UIColor(red: 186/255, green: 45/255, blue: 37/255, alpha: 1.0) // Red
                MeetingstatusLbl.backgroundColor = UIColor(red: 254/255, green: 242/255, blue: 242/255, alpha: 1.0)
            } else {
                MeetingstatusLbl.text = "  \(parentResponse.statusDisplayText)  "
                MeetingstatusLbl.textColor = .systemOrange
                MeetingstatusLbl.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.12)
            }
        } else {
            // 2) Fallback to Meeting Status (Scheduled, Cancelled, Completed, etc.)
            let mStatus = meeting.status.uppercased()
            if mStatus == "SCHEDULED" || mStatus == "ACTIVE" {
                MeetingstatusLbl.text = "  Pending RSVP  "
                MeetingstatusLbl.textColor = UIColor(red: 31/255, green: 71/255, blue: 127/255, alpha: 1.0) // Theme Blue
                MeetingstatusLbl.backgroundColor = UIColor(red: 31/255, green: 71/255, blue: 127/255, alpha: 0.1)
            } else if mStatus == "CANCELLED" {
                MeetingstatusLbl.text = "  Cancelled  "
                MeetingstatusLbl.textColor = .systemGray
                MeetingstatusLbl.backgroundColor = UIColor.systemGray.withAlphaComponent(0.15)
            } else if mStatus == "COMPLETED" {
                MeetingstatusLbl.text = "  Completed  "
                MeetingstatusLbl.textColor = .systemGreen
                MeetingstatusLbl.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.15)
            } else {
                MeetingstatusLbl.text = "  \(mStatus.capitalized)  "
                MeetingstatusLbl.textColor = .darkGray
                MeetingstatusLbl.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
            }
        }
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
