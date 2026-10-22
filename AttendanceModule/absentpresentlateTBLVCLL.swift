//
//  absentpresentlateTBLVCLL.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 22/10/26.
//

import UIKit

class absentpresentlateTBLVCLL: UITableViewCell {

    @IBOutlet weak var ReasonLabel: UILabel!

    // Main title in the middle: Present / Absent / Late / Leave
    @IBOutlet weak var AttendencestatusLabel: UILabel!

    // Existing vertical color strip on the left
    @IBOutlet weak var Colorview: UIView!

    @IBOutlet weak var Reaqestdate: UILabel!
    @IBOutlet weak var Backgroundview: UIView!

    // Small status badge on the right
    @IBOutlet weak var AttendancestatusLabel2: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none

        // Card
        Backgroundview.layer.cornerRadius = 12
        Backgroundview.layer.borderWidth = 1
        Backgroundview.clipsToBounds = true

        // Keep this as the existing thin vertical strip.
        Colorview.layer.cornerRadius = 2
        Colorview.clipsToBounds = true

        // Main title — plain text, NOT a pill.
        AttendencestatusLabel.backgroundColor = .clear
        AttendencestatusLabel.layer.cornerRadius = 0
        AttendencestatusLabel.layer.borderWidth = 0
        AttendencestatusLabel.layer.masksToBounds = false
        AttendencestatusLabel.textAlignment = .left
        AttendencestatusLabel.font = UIFont.systemFont(
            ofSize: 16,
            weight: .bold
        )
        AttendencestatusLabel.numberOfLines = 1

        // Right-side status badge.
        AttendancestatusLabel2.textAlignment = .center
        AttendancestatusLabel2.font = UIFont.systemFont(
            ofSize: 12,
            weight: .semibold
        )
        AttendancestatusLabel2.numberOfLines = 1
        AttendancestatusLabel2.adjustsFontSizeToFitWidth = true
        AttendancestatusLabel2.minimumScaleFactor = 0.8
        AttendancestatusLabel2.clipsToBounds = true

        // Reason below the main title.
        ReasonLabel.font = UIFont.systemFont(
            ofSize: 12,
            weight: .regular
        )
        ReasonLabel.textColor = color(0x64748B)
        ReasonLabel.backgroundColor = .clear
        ReasonLabel.textAlignment = .left
        ReasonLabel.numberOfLines = 1
        ReasonLabel.lineBreakMode = .byTruncatingTail

        // Two-line date, for example: Wed / 21 Oct.
        Reaqestdate.font = UIFont.systemFont(
            ofSize: 12,
            weight: .semibold
        )
        Reaqestdate.numberOfLines = 2
        Reaqestdate.textAlignment = .left
        Reaqestdate.backgroundColor = .clear

        applyStatusColors(for: "")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // Rounded pill only for the small right-side badge.
        AttendancestatusLabel2.layer.cornerRadius =
            AttendancestatusLabel2.bounds.height / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        // Remove previous record content when the cell is reused.
        ReasonLabel.text = nil
        AttendencestatusLabel.text = nil
        AttendancestatusLabel2.text = nil
        Reaqestdate.text = nil

        applyStatusColors(for: "")
    }

    // MARK: - Configure Attendance Record
    func configure(with record: FetchStudentAttendanceRecord) {

        let status = (record.status ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()

        let displayStatus = status.isEmpty
            ? "—"
            : status.replacingOccurrences(of: "_", with: " ").capitalized

        // Update BOTH status labels for every record.
        AttendencestatusLabel.text = displayStatus
        AttendancestatusLabel2.text = displayStatus

        // Always assign the date, including when it is missing.
        Reaqestdate.text = formattedDate(record.attendanceDate)

        // Use the actual API remarks when available.
        let remarks = (record.remarks ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        ReasonLabel.text = remarks.isEmpty
            ? getDefaultRemark(for: status)
            : remarks

        // Apply all status-dependent colors on every configuration.
        applyStatusColors(for: status)
    }

    // MARK: - Status Colors
    private func applyStatusColors(for status: String) {

        // Neutral appearance for missing or unrecognized statuses.
        var stripColor = color(0x94A3B8)
        var dateColor = color(0x64748B)
        var cardColor = UIColor.white
        var borderColor = color(0xE2E8F0)
        var badgeBackgroundColor = color(0xF1F5F9)
        var badgeTextColor = color(0x475569)

        switch status {

        case "PRESENT":
            // Green strip, date and badge.
            stripColor = color(0x22C55E)
            dateColor = color(0x15803D)
            cardColor = .white
            borderColor = color(0xE2E8F0)
            badgeBackgroundColor = color(0xD1FAE5)
            badgeTextColor = color(0x065F46)

        case "ABSENT":
            // Red strip, date and badge with a light red card.
            stripColor = color(0xEF4444)
            dateColor = color(0xB91C1C)
            cardColor = color(0xFEF2F2)
            borderColor = color(0xFCA5A5)
            badgeBackgroundColor = color(0xFEE2E2)
            badgeTextColor = color(0xB91C1C)

        case "LATE":
            // Amber strip, date and badge with a light amber card.
            stripColor = color(0xF59E0B)
            dateColor = color(0xB45309)
            cardColor = color(0xFFF7E0)
            borderColor = color(0xFCD56D)
            badgeBackgroundColor = color(0xFDE9B3)
            badgeTextColor = color(0xB45309)

        case "LEAVE":
            // Muted blue strip/date and a blue badge on a white card.
            stripColor = color(0x5B7FA7)
            dateColor = color(0x5B7FA7)
            cardColor = .white
            borderColor = color(0xE2E8F0)
            badgeBackgroundColor = color(0xDBEAFE)
            badgeTextColor = color(0x1D4ED8)

        default:
            break
        }

        // Existing left-side vertical strip.
        Colorview.backgroundColor = stripColor

        // Date color must also change for each record.
        Reaqestdate.textColor = dateColor

        // Card appearance.
        Backgroundview.backgroundColor = cardColor
        Backgroundview.layer.borderColor = borderColor.cgColor

        // Main title stays plain navy, as in the Figma design.
        AttendencestatusLabel.textColor = color(0x102D4F)
        AttendencestatusLabel.backgroundColor = .clear

        // Only the small right label receives the badge colors.
        AttendancestatusLabel2.textColor = badgeTextColor
        AttendancestatusLabel2.backgroundColor = badgeBackgroundColor

        // Reason remains gray.
        ReasonLabel.textColor = color(0x64748B)
    }

    // MARK: - Date Formatting
    private func formattedDate(_ dateString: String?) -> String {
        guard let dateString = dateString,
              !dateString.isEmpty else {
            return "—"
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"

        guard let date = formatter.date(from: dateString) else {
            return dateString
        }

        formatter.dateFormat = "EEE\ndd MMM"
        return formatter.string(from: date)
    }

    // MARK: - Fallback for Empty API Remarks
    private func getDefaultRemark(for status: String) -> String {
        switch status {
        case "PRESENT":
            return "On time"
        case "ABSENT":
            return "Absent"
        case "LATE":
            return "Late arrival"
        case "LEAVE":
            return "On leave"
        case "HALF_DAY":
            return "Half day"
        default:
            return ""
        }
    }

    // MARK: - Local Color Helper
    private func color(_ hex: UInt32) -> UIColor {
        return UIColor(
            red: CGFloat((hex >> 16) & 0xFF) / 255.0,
            green: CGFloat((hex >> 8) & 0xFF) / 255.0,
            blue: CGFloat(hex & 0xFF) / 255.0,
            alpha: 1.0
        )
    }
}
