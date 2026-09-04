//
//  PTMpastmeetingTableViewCell.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 18/07/26.
//

import UIKit

class PTMpastmeetingTableViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var StatusLbl: UIView!
    @IBOutlet weak var StudentnameLbl: UILabel!
    @IBOutlet weak var MeetingmonthLbl: UILabel!
    @IBOutlet weak var MeetingtimeLbl: UILabel!
    @IBOutlet weak var StaffnameLbl: UILabel!
    @IBOutlet weak var StudentgradeLbl: UILabel!
    @IBOutlet weak var MeetingtitleLbl: UILabel!

    // MARK: - Optional Status Label (if you have a UILabel inside StatusLbl view)
    private var statusTextLabel: UILabel?

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupStatusView()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        StudentnameLbl.text     = nil
        MeetingmonthLbl.text    = nil
        MeetingtimeLbl.text     = nil
        StaffnameLbl.text       = nil
        StudentgradeLbl.text    = nil
        MeetingtitleLbl.text    = nil
        statusTextLabel?.text   = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: - Setup Status View (Programmatic Label)
    private func setupStatusView() {
        // Create a status label programmatically inside StatusLbl (which is a UIView)
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        label.textColor = .white

        StatusLbl.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: StatusLbl.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: StatusLbl.centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: StatusLbl.leadingAnchor, constant: 6),
            label.trailingAnchor.constraint(lessThanOrEqualTo: StatusLbl.trailingAnchor, constant: -6)
        ])

        self.statusTextLabel = label

        StatusLbl.layer.cornerRadius = 6
        StatusLbl.clipsToBounds = true
    }

    // MARK: - Configure with Completed Meeting Data
    func configure(with meeting: PTMCompletedMeeting, studentName: String) {

        // ── Meeting Title ─────────────────────────────────────────────
        MeetingtitleLbl.text = meeting.title.isEmpty
            ? "Parent Teacher Meeting"
            : meeting.title

        // ── Student Name ──────────────────────────────────────────────
        StudentnameLbl.text = studentName.isEmpty ? "Student" : studentName

        // ── Student Grade (from UserManager if available) ─────────────
        if let kid = UserManager.shared.selectedKid {
            let grade = kid.grade ?? ""
            let section = kid.section ?? ""
            StudentgradeLbl.text = "\(grade) - \(section)"
        } else {
            StudentgradeLbl.text = "—"
        }

        // ── Meeting Date (Month/Day) ──────────────────────────────────
        MeetingmonthLbl.text = meeting.formattedDate

        // ── Meeting Time Range ────────────────────────────────────────
        MeetingtimeLbl.text = meeting.formattedTimeRange

        // ── Staff Name (Host or First Staff) ──────────────────────────
        if let host = meeting.hostStaff {
            StaffnameLbl.text = host.name
        } else if let firstStaff = meeting.staffs.first {
            StaffnameLbl.text = firstStaff.name
        } else {
            StaffnameLbl.text = "—"
        }

        // ── Configure Status Badge (StatusLbl UIView) ─────────────────
        configureStatusView(meeting: meeting)

        print("✅ PTMpastmeetingTableViewCell configured:")
        print("   title  : \(MeetingtitleLbl.text ?? "")")
        print("   date   : \(MeetingmonthLbl.text ?? "")")
        print("   time   : \(MeetingtimeLbl.text  ?? "")")
        print("   staff  : \(StaffnameLbl.text    ?? "")")
        print("   status : \(meeting.attendanceStatus)")
    }

    // MARK: - Configure Status View
    private func configureStatusView(meeting: PTMCompletedMeeting) {

        let status = meeting.attendanceStatus.uppercased()

        switch status {
        case "ATTENDED":
            statusTextLabel?.text = "Attended"
            statusTextLabel?.textColor = UIColor(red: 46/255, green: 117/255, blue: 89/255, alpha: 1.0)
            StatusLbl.backgroundColor = UIColor(red: 235/255, green: 247/255, blue: 242/255, alpha: 1.0)

        case "ABSENT":
            statusTextLabel?.text = "Absent"
            statusTextLabel?.textColor = UIColor(red: 186/255, green: 45/255, blue: 37/255, alpha: 1.0)
            StatusLbl.backgroundColor = UIColor(red: 254/255, green: 242/255, blue: 242/255, alpha: 1.0)

        case "NOT_MARKED":
            statusTextLabel?.text = "Not Marked"
            statusTextLabel?.textColor = .darkGray
            StatusLbl.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)

        default:
            statusTextLabel?.text = status.capitalized
            statusTextLabel?.textColor = .darkGray
            StatusLbl.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        }
    }
}
