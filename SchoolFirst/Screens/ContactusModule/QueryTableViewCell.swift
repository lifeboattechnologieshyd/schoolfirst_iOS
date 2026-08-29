//
//  QueryTableViewCell.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 20/08/26.
//

import UIKit

class QueryTableViewCell: UITableViewCell {

    @IBOutlet weak var TicketidLbl: UILabel!
    @IBOutlet weak var StatusLbl: UILabel!
    @IBOutlet weak var CreatedtimeLbl: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    private func setupUI() {

        // ==========================================
        // STATUS PILL (Figma Style)
        // ==========================================

        StatusLbl.font = UIFont.systemFont(
            ofSize: 12,
            weight: .medium
        )

        StatusLbl.textAlignment = .center
        StatusLbl.layer.cornerRadius = 8
        StatusLbl.clipsToBounds = true

        // Make width dynamic — hug the text, never stretch
        StatusLbl.setContentHuggingPriority(
            .required,
            for: .horizontal
        )

        StatusLbl.setContentCompressionResistancePriority(
            .required,
            for: .horizontal
        )

        // ==========================================
        // TITLE & DESCRIPTION
        // ==========================================

        titleLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byTruncatingTail

        descriptionLabel.numberOfLines = 3
        descriptionLabel.lineBreakMode = .byTruncatingTail
        descriptionLabel.textColor = .darkGray
    }

    override func setSelected(
        _ selected: Bool,
        animated: Bool
    ) {
        super.setSelected(
            selected,
            animated: animated
        )
    }

    // ==========================================
    // MARK: - Configure
    // ==========================================

    func configure(with ticket: TicketItem) {

        // ==========================================
        // Ticket ID Label
        // Shows only last 6 characters
        // ==========================================

        if let id = ticket.id,
           !id.trimmingCharacters(
                in: .whitespacesAndNewlines
           ).isEmpty {

            TicketidLbl.text =
                "\(shortTicketId(from: id))"

        } else {

            TicketidLbl.text = ""
        }

        // ==========================================
        // Title Label
        // Display title in UPPERCASE
        // ==========================================

        if let title = ticket.title?
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            ),
           !title.isEmpty {

            titleLabel.text = title.uppercased()

        } else {

            titleLabel.text = "NO TITLE"
        }

        // ==========================================
        // Description Label
        // ==========================================

        let cleanDescription =
            ticket.description?
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        if let desc = cleanDescription,
           !desc.isEmpty {

            descriptionLabel.text = desc

        } else {

            descriptionLabel.text =
                "No Description Provided"
        }

        // ==========================================
        // Status Pill
        // ==========================================

        configureStatusBadge(ticket.status)

        // ==========================================
        // Created Time
        // Show relative time
        // ==========================================

        if let rawDate = ticket.createdAt,
           !rawDate.isEmpty {

            CreatedtimeLbl.text =
                relativeTime(from: rawDate)

        } else {

            CreatedtimeLbl.text = ""
        }
    }

    // ==========================================
    // MARK: - Status Badge
    // ==========================================

    private func configureStatusBadge(
        _ rawStatus: String?
    ) {

        // Normalize:
        // "REPLY_SENT" -> "REPLY SENT"

        let status =
            (rawStatus ?? "OPEN")
            .replacingOccurrences(
                of: "_",
                with: " "
            )
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .uppercased()

        // Display text like Figma:
        // "Open", "Reply Sent", "Resolved"

        StatusLbl.text =
            status.capitalized

        switch status {

        case "OPEN":

            // Blue pill
            StatusLbl.textColor =
                UIColor(
                    red: 45 / 255,
                    green: 107 / 255,
                    blue: 216 / 255,
                    alpha: 1
                )

            StatusLbl.backgroundColor =
                UIColor(
                    red: 220 / 255,
                    green: 233 / 255,
                    blue: 251 / 255,
                    alpha: 1
                )

        case "REPLY SENT":

            // Amber pill
            StatusLbl.textColor =
                UIColor(
                    red: 197 / 255,
                    green: 130 / 255,
                    blue: 20 / 255,
                    alpha: 1
                )

            StatusLbl.backgroundColor =
                UIColor(
                    red: 255 / 255,
                    green: 243 / 255,
                    blue: 214 / 255,
                    alpha: 1
                )

        case "RESOLVED":

            // Green pill
            StatusLbl.textColor =
                UIColor(
                    red: 30 / 255,
                    green: 158 / 255,
                    blue: 80 / 255,
                    alpha: 1
                )

            StatusLbl.backgroundColor =
                UIColor(
                    red: 223 / 255,
                    green: 244 / 255,
                    blue: 229 / 255,
                    alpha: 1
                )

        case "IN PROGRESS", "PENDING":

            // Amber pill
            StatusLbl.textColor =
                UIColor(
                    red: 197 / 255,
                    green: 130 / 255,
                    blue: 20 / 255,
                    alpha: 1
                )

            StatusLbl.backgroundColor =
                UIColor(
                    red: 255 / 255,
                    green: 243 / 255,
                    blue: 214 / 255,
                    alpha: 1
                )

        case "CLOSED":

            // Gray pill
            StatusLbl.textColor =
                UIColor.systemGray

            StatusLbl.backgroundColor =
                UIColor.systemGray
                    .withAlphaComponent(0.15)

        default:

            // Fallback gray pill
            StatusLbl.textColor =
                UIColor.systemGray

            StatusLbl.backgroundColor =
                UIColor.systemGray
                    .withAlphaComponent(0.15)
        }

        // Dynamic width
        StatusLbl.sizeToFit()
    }

    // ==========================================
    // MARK: - Ticket ID Helper
    // ==========================================

    private func shortTicketId(
        from id: String
    ) -> String {

        let cleaned =
            id
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .replacingOccurrences(
                of: "",
                with: ""
            )
            .replacingOccurrences(
                of: "-",
                with: ""
            )

        guard !cleaned.isEmpty else {
            return ""
        }

        // ==========================================
        // Show LAST 6 characters
        // ==========================================

        guard cleaned.count > 6 else {
            return cleaned.uppercased()
        }

        return String(
            cleaned.suffix(6)
        ).uppercased()
    }

    // ==========================================
    // MARK: - Date Parsing
    // ==========================================

    private func parseServerDate(
        _ dateString: String
    ) -> Date? {

        // ------------------------------------------
        // ISO8601 with fractional seconds
        // Example:
        // 2026-08-29T10:30:25.123Z
        // ------------------------------------------

        let isoFormatter =
            ISO8601DateFormatter()

        isoFormatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]

        if let date =
            isoFormatter.date(
                from: dateString
            ) {

            return date
        }

        // ------------------------------------------
        // ISO8601 without fractional seconds
        // Example:
        // 2026-08-29T10:30:25Z
        // ------------------------------------------

        isoFormatter.formatOptions = [
            .withInternetDateTime
        ]

        if let date =
            isoFormatter.date(
                from: dateString
            ) {

            return date
        }

        // ------------------------------------------
        // Custom date formats
        // ------------------------------------------

        let customFormatter =
            DateFormatter()

        customFormatter.locale =
            Locale(
                identifier: "en_US_POSIX"
            )

        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ",
            "yyyy-MM-dd'T'HH:mm:ss.SSSSZ",
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd"
        ]

        for format in formats {

            customFormatter.dateFormat =
                format

            if let date =
                customFormatter.date(
                    from: dateString
                ) {

                return date
            }
        }

        return nil
    }

    // ==========================================
    // MARK: - Relative Time
    // ==========================================

    private func relativeTime(
        from dateString: String
    ) -> String {

        // Convert server string to Date
        guard let date =
            parseServerDate(dateString)
        else {

            // If parsing fails,
            // return original value

            return dateString
        }

        let now = Date()

        let difference =
            now.timeIntervalSince(date)

        // Future date protection
        if difference < 0 {
            return "Just now"
        }

        let seconds =
            Int(difference)

        // ==========================================
        // Less than 1 minute
        // ==========================================

        if seconds < 60 {
            return "Just now"
        }

        // ==========================================
        // Minutes
        // ==========================================

        let minutes =
            seconds / 60

        if minutes < 60 {

            if minutes == 1 {

                return "1 min ago"

            } else {

                return "\(minutes) mins ago"
            }
        }

        // ==========================================
        // Hours
        // ==========================================

        let hours =
            minutes / 60

        if hours < 24 {

            if hours == 1 {

                return "1 hour ago"

            } else {

                return "\(hours) hours ago"
            }
        }

        // ==========================================
        // Days
        // ==========================================

        let days =
            hours / 24

        if days < 7 {

            if days == 1 {

                return "1 day ago"

            } else {

                return "\(days) days ago"
            }
        }

        // ==========================================
        // Weeks
        // ==========================================

        let weeks =
            days / 7

        if weeks < 4 {

            if weeks == 1 {

                return "1 week ago"

            } else {

                return "\(weeks) weeks ago"
            }
        }

        // ==========================================
        // Months
        // ==========================================

        let months =
            days / 30

        if months < 12 {

            if months == 1 {

                return "1 month ago"

            } else {

                return "\(months) months ago"
            }
        }

        // ==========================================
        // Years
        // ==========================================

        let years =
            days / 365

        if years == 1 {

            return "1 year ago"

        } else {

            return "\(years) years ago"
        }
    }
}

// ==========================================
// MARK: - Status Pill Label
// ==========================================

class StatusPillLabel: UILabel {

    var textInsets =
        UIEdgeInsets(
            top: 4,
            left: 12,
            bottom: 4,
            right: 12
        ) {

        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override func drawText(
        in rect: CGRect
    ) {

        super.drawText(
            in: rect.inset(
                by: textInsets
            )
        )
    }

    override var intrinsicContentSize: CGSize {

        let size =
            super.intrinsicContentSize

        return CGSize(
            width:
                size.width +
                textInsets.left +
                textInsets.right,

            height:
                size.height +
                textInsets.top +
                textInsets.bottom
        )
    }

    override func sizeThatFits(
        _ size: CGSize
    ) -> CGSize {

        let fit =
            super.sizeThatFits(size)

        return CGSize(
            width:
                fit.width +
                textInsets.left +
                textInsets.right,

            height:
                fit.height +
                textInsets.top +
                textInsets.bottom
        )
    }
}
