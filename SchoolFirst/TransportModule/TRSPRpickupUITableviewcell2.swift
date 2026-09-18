//
//  TRSPRpickupUITableviewcell2.swift
//  SchoolFirst
//

import UIKit

class TRSPRpickupUITableviewcell2: UITableViewCell {

    @IBOutlet weak var Ckeckmarkimageview: UIImageView!
    @IBOutlet weak var imagebackgroundview: UIView!
    @IBOutlet weak var PickupandDroptimelabel: UILabel!
    @IBOutlet weak var StopnameLabel: UILabel!

    // Optional: if wired in XIB
    @IBOutlet weak var statusBadgeLabel: UILabel?
    @IBOutlet weak var timelineTopLine: UIView?
    @IBOutlet weak var timelineBottomLine: UIView?

    override func awakeFromNib() {
        super.awakeFromNib()
        imagebackgroundview?.layer.cornerRadius = (imagebackgroundview?.frame.height ?? 24) / 2
        imagebackgroundview?.clipsToBounds = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        StopnameLabel.text = nil
        PickupandDroptimelabel.text = nil
        statusBadgeLabel?.text = nil
        statusBadgeLabel?.isHidden = true
        Ckeckmarkimageview?.image = nil
        contentView.backgroundColor = .clear
    }

    /// Configure one route stop row
    func configure(
        stopName: String?,
        time: String?,
        isYourStop: Bool = false,
        isFirst: Bool = false,
        isLast: Bool = false,
        stopOrder: Int? = nil,
        isDrop: Bool = false
    ) {
        // Stop Name
        let name = stopName?.trimmingCharacters(in: .whitespacesAndNewlines)
        StopnameLabel.text = (name?.isEmpty == false) ? name : "N/A"

        // Time -> Formatted safely to AM / PM
        PickupandDroptimelabel.text = Self.formatTime(time, isDrop: isDrop)

        // Your stop highlight
        if isYourStop {
            StopnameLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            statusBadgeLabel?.isHidden = false
            statusBadgeLabel?.text = "YOUR STOP"
            contentView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.06)
            imagebackgroundview?.backgroundColor = UIColor.systemBlue
            Ckeckmarkimageview?.image = UIImage(systemName: "mappin.circle.fill")
            Ckeckmarkimageview?.tintColor = .white
        } else {
            StopnameLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            statusBadgeLabel?.isHidden = true
            contentView.backgroundColor = .clear
            imagebackgroundview?.backgroundColor = UIColor.systemGray5
            Ckeckmarkimageview?.image = UIImage(systemName: "circle")
            Ckeckmarkimageview?.tintColor = UIColor.systemGray3
        }

        // Timeline connectors
        timelineTopLine?.isHidden = isFirst
        timelineBottomLine?.isHidden = isLast
    }

    // MARK: - Time Formatter (Morning = AM, Evening/After 12 = PM, Drop context = PM)
    static func formatTime(_ raw: String?, isDrop: Bool = false) -> String {
        guard var value = raw?.trimmingCharacters(in: .whitespacesAndNewlines),
              !value.isEmpty else {
            return "--:--"
        }

        let upper = value.uppercased()

        // 1. If string already explicitly contains AM/PM
        if upper.contains("AM") || upper.contains("PM") {
            let ampmFormats = ["hh:mm a", "h:mm a", "hh:mm:ss a", "h:mm:ss a", "hh:mma", "h:mma"]
            for format in ampmFormats {
                let parser = DateFormatter()
                parser.locale = Locale(identifier: "en_US_POSIX")
                parser.dateFormat = format
                if let date = parser.date(from: value) {
                    return displayFormatter.string(from: date)
                }
            }
            return upper
                .replacingOccurrences(of: "AM", with: " AM")
                .replacingOccurrences(of: "PM", with: " PM")
                .replacingOccurrences(of: "  ", with: " ")
                .trimmingCharacters(in: .whitespaces)
        }

        // 2. Remove fractional seconds e.g. "08:00:00.200000" -> "08:00:00"
        if let dotIndex = value.firstIndex(of: ".") {
            let timePart = String(value[..<dotIndex])
            let parts = timePart.components(separatedBy: ":")
            if parts.count >= 2 {
                value = timePart
            }
        }

        // 3. Parse standard 24-hr or ISO formats
        let inputFormats = [
            "HH:mm:ss",
            "H:mm:ss",
            "HH:mm",
            "H:mm",
            "yyyy-MM-dd'T'HH:mm:ss",
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd HH:mm:ss"
        ]

        var parsedDate: Date?
        for format in inputFormats {
            let parser = DateFormatter()
            parser.locale = Locale(identifier: "en_US_POSIX")
            parser.dateFormat = format
            if let date = parser.date(from: value) {
                parsedDate = date
                break
            }
        }

        guard let date = parsedDate else {
            return value
        }

        let calendar = Calendar.current
        var hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)

        // 4. Evening Drop Context Adjustment
        // If it's an Evening Drop and the API returns 12-hour hour without PM tag (e.g. 03:30 or 04:15),
        // treat hours 1..11 during Drop as PM (afternoon/evening drop)
        if isDrop && hour >= 1 && hour <= 11 {
            hour += 12
            var components = DateComponents()
            components.hour = hour
            components.minute = minute
            if let updatedDate = calendar.date(from: components) {
                return displayFormatter.string(from: updatedDate)
            }
        }

        return displayFormatter.string(from: date)
    }

    private static let displayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "hh:mm a"   // Outputs e.g. "07:30 AM" or "04:30 PM"
        return f
    }()

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
