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

        StatusLbl.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        StatusLbl.textAlignment = .center
        StatusLbl.layer.cornerRadius = 8
        StatusLbl.clipsToBounds = true

        // Make width dynamic — hug the text, never stretch
        StatusLbl.setContentHuggingPriority(.required, for: .horizontal)
        StatusLbl.setContentCompressionResistancePriority(.required, for: .horizontal)

        // ==========================================
        // TITLE & DESCRIPTION
        // ==========================================

        titleLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byTruncatingTail

        descriptionLabel.numberOfLines = 3
        descriptionLabel.lineBreakMode = .byTruncatingTail
        descriptionLabel.textColor = .darkGray
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: - Configure

    func configure(with ticket: TicketItem) {

        // Configure Ticket ID Label (shows only last 3 characters)
        if let id = ticket.id, !id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            TicketidLbl.text = "#\(shortTicketId(from: id))"
        } else {
            TicketidLbl.text = ""
        }

        // Configure Title Label
        titleLabel.text = (ticket.title?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false)
            ? ticket.title
            : "No Title"

        // Configure Description Label
        let cleanDescription = ticket.description?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let desc = cleanDescription, !desc.isEmpty {
            descriptionLabel.text = desc
        } else {
            descriptionLabel.text = "No Description Provided"
        }

        // Configure Status Pill (Figma colors)
        configureStatusBadge(ticket.status)

        // Configure Date Label
        if let rawDate = ticket.createdAt, !rawDate.isEmpty {
            CreatedtimeLbl.text = formatServerDate(rawDate)
        } else {
            CreatedtimeLbl.text = ""
        }
    }

    // MARK: - Status Badge (Figma Colors + Dynamic Width)

    private func configureStatusBadge(_ rawStatus: String?) {

        // Normalize: "REPLY_SENT" -> "REPLY SENT"
        let status = (rawStatus ?? "OPEN")
            .replacingOccurrences(of: "_", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()

        // Display text like Figma: "Open", "Reply Sent", "Resolved"
        StatusLbl.text = status.capitalized

        switch status {

        case "OPEN":
            // Blue pill (Figma "Open")
            StatusLbl.textColor = UIColor(red: 45/255, green: 107/255, blue: 216/255, alpha: 1)
            StatusLbl.backgroundColor = UIColor(red: 220/255, green: 233/255, blue: 251/255, alpha: 1)

        case "REPLY SENT":
            // Amber pill (Figma "Reply Sent")
            StatusLbl.textColor = UIColor(red: 197/255, green: 130/255, blue: 20/255, alpha: 1)
            StatusLbl.backgroundColor = UIColor(red: 255/255, green: 243/255, blue: 214/255, alpha: 1)

        case "RESOLVED":
            // Green pill (Figma "Resolved")
            StatusLbl.textColor = UIColor(red: 30/255, green: 158/255, blue: 80/255, alpha: 1)
            StatusLbl.backgroundColor = UIColor(red: 223/255, green: 244/255, blue: 229/255, alpha: 1)

        case "IN PROGRESS", "PENDING":
            // Amber pill (same tone as Reply Sent)
            StatusLbl.textColor = UIColor(red: 197/255, green: 130/255, blue: 20/255, alpha: 1)
            StatusLbl.backgroundColor = UIColor(red: 255/255, green: 243/255, blue: 214/255, alpha: 1)

        case "CLOSED":
            // Gray pill
            StatusLbl.textColor = UIColor.systemGray
            StatusLbl.backgroundColor = UIColor.systemGray.withAlphaComponent(0.15)

        default:
            // Fallback gray pill
            StatusLbl.textColor = UIColor.systemGray
            StatusLbl.backgroundColor = UIColor.systemGray.withAlphaComponent(0.15)
        }

        // Remove old manual space-padding (pill handles padding now)
        StatusLbl.sizeToFit()
    }

    // MARK: - Ticket ID Helper

    private func shortTicketId(from id: String) -> String {

        let cleaned = id
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
            .replacingOccurrences(of: "-", with: "")

        guard !cleaned.isEmpty else { return "" }
        guard cleaned.count > 3 else { return cleaned.uppercased() }

        return String(cleaned.suffix(3)).uppercased()
    }

    // MARK: - Date Helpers

    private func formatServerDate(_ dateString: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFormatter.date(from: dateString) {
            return displayFormattedDate(date)
        }

        isoFormatter.formatOptions = [.withInternetDateTime]
        if let date = isoFormatter.date(from: dateString) {
            return displayFormattedDate(date)
        }

        let customFormatter = DateFormatter()
        customFormatter.locale = Locale(identifier: "en_US_POSIX")

        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ",
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd"
        ]

        for format in formats {
            customFormatter.dateFormat = format
            if let date = customFormatter.date(from: dateString) {
                return displayFormattedDate(date)
            }
        }

        return dateString
    }

    private func displayFormattedDate(_ date: Date) -> String {
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "dd MMM yyyy, hh:mm a"
        return displayFormatter.string(from: date)
    }
}

class StatusPillLabel: UILabel {

    var textInsets = UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12) {
        didSet { invalidateIntrinsicContentSize() }
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + textInsets.left + textInsets.right,
            height: size.height + textInsets.top + textInsets.bottom
        )
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let fit = super.sizeThatFits(size)
        return CGSize(
            width: fit.width + textInsets.left + textInsets.right,
            height: fit.height + textInsets.top + textInsets.bottom
        )
    }
}
