//
//  PTMcompletedmeetingsCollectionViewCell.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 19/06/26.
//

import UIKit

class PTMcompletedmeetingsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var StaffnameLbl: UILabel!
    @IBOutlet weak var MeetingtitleLbl: UILabel!
    @IBOutlet weak var MeetindateLbl: UILabel!
    @IBOutlet weak var MeetingmonthLbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        StaffnameLbl.text     = nil
        MeetingtitleLbl.text  = nil
        MeetindateLbl.text    = nil
        MeetingmonthLbl.text  = nil
    }

    // MARK: - Configure with completed meeting data
    func configure(with meeting: PTMCompletedMeeting) {

        // Meeting title
        MeetingtitleLbl.text = meeting.title.isEmpty
            ? "Parent-Teacher Meeting"
            : meeting.title

        // Staff — prefer host staff, then first staff
        if let host = meeting.hostStaff {
            StaffnameLbl.text = host.name
        } else if let first = meeting.staffs.first {
            StaffnameLbl.text = first.name
        } else {
            StaffnameLbl.text = "No Staff Assigned"
        }

        // Split date into day + month e.g. "2026-07-20" → "20" & "JUL"
        let (dayStr, monthStr) = splitDate(meeting.meetingDate)
        MeetindateLbl.text   = dayStr
        MeetingmonthLbl.text = monthStr

        print("🟢 Completed cell configured:", meeting.title,
              "| date:", dayStr, monthStr,
              "| staff:", StaffnameLbl.text ?? "-")
    }

    // MARK: - Empty state
    func configureEmpty() {
        MeetingtitleLbl.text = "No completed meetings"
        StaffnameLbl.text    = ""
        MeetindateLbl.text   = "--"
        MeetingmonthLbl.text = "---"
    }

    // MARK: - Helper: split "yyyy-MM-dd" → ("20", "JUL")
    private func splitDate(_ dateString: String) -> (String, String) {

        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"

        guard let date = inputFormatter.date(from: dateString) else {
            return ("--", "---")
        }

        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "dd"

        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMM"

        let day   = dayFormatter.string(from: date)
        let month = monthFormatter.string(from: date).uppercased()

        return (day, month)
    }
}
