//
//  LeaverequestsTBLVCLL2.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 21/10/26.
//

import UIKit

class LeaverequestsTBLVCLL2: UITableViewCell {

    @IBOutlet weak var Statuslabel: UILabel!
    @IBOutlet weak var ReasonLabel: UILabel!
    @IBOutlet weak var RequestdateLabel: UILabel!
    @IBOutlet weak var Backgroundview: UIView!

    @IBOutlet weak var Colorhorizantalview: UIView!

    @IBOutlet weak var RemarkLabel: UILabel!
    @IBOutlet weak var RequestanddateLabel: UILabel!
    @IBOutlet weak var Horizantolcolorview: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        setupInitialUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        Statuslabel.text = nil
        ReasonLabel.text = nil
        RequestdateLabel.text = nil
        RemarkLabel.text = nil
        RequestanddateLabel.text = nil
    }

    private func setupInitialUI() {
        Backgroundview.layer.cornerRadius = 12
        Backgroundview.layer.borderWidth = 1
        Backgroundview.clipsToBounds = true

        Statuslabel.layer.cornerRadius = 9
        Statuslabel.layer.masksToBounds = true
        Statuslabel.textAlignment = .center
        Statuslabel.font = .systemFont(ofSize: 11, weight: .semibold)

        ReasonLabel.font = .systemFont(ofSize: 15, weight: .bold)
        ReasonLabel.textColor = UIColor(
            red: 0.02,
            green: 0.19,
            blue: 0.38,
            alpha: 1.0
        )
        ReasonLabel.numberOfLines = 2
        ReasonLabel.lineBreakMode = .byTruncatingTail

        RemarkLabel.font = .systemFont(ofSize: 12, weight: .medium)
        RemarkLabel.textColor = UIColor(
            red: 0.38,
            green: 0.46,
            blue: 0.60,
            alpha: 1.0
        )
        RemarkLabel.numberOfLines = 1
        RemarkLabel.lineBreakMode = .byTruncatingTail

        RequestdateLabel.font = .systemFont(ofSize: 11, weight: .bold)
        RequestdateLabel.numberOfLines = 2
        RequestdateLabel.textAlignment = .left
        RequestdateLabel.lineBreakMode = .byTruncatingTail

        RequestanddateLabel.font = .systemFont(ofSize: 11, weight: .bold)
        RequestanddateLabel.numberOfLines = 2
        RequestanddateLabel.textAlignment = .left
        RequestanddateLabel.lineBreakMode = .byTruncatingTail

        Colorhorizantalview.layer.cornerRadius = 2
        Colorhorizantalview.clipsToBounds = true

        Horizantolcolorview.layer.cornerRadius = 2
        Horizantolcolorview.clipsToBounds = true
    }

    // MARK: - Configure API Data

    func configure(
        with leave: LeaveListItem,
        requestNumber: Int
    ) {
        let status = leave.status.uppercased()
        let style = styleForStatus(status)

        Backgroundview.backgroundColor = style.cardBackground
        Backgroundview.layer.borderColor = style.borderColor.cgColor

        Colorhorizantalview.backgroundColor = style.accentColor
        Horizantolcolorview.backgroundColor = style.accentColor

        Statuslabel.text = "  \(status.capitalized)  "
        Statuslabel.textColor = style.statusTextColor
        Statuslabel.backgroundColor = style.statusBackground

        RequestanddateLabel.textColor = style.accentColor
        RequestanddateLabel.text = "Request \(requestNumber)"

        RequestdateLabel.textColor = style.accentColor
        RequestdateLabel.text = compactDateText(
            start: leave.startDate,
            end: leave.endDate
        )

        ReasonLabel.text = titleText(from: leave)
        RemarkLabel.text = remarkText(from: leave)
    }

    // MARK: - Text Helpers

    private func titleText(from leave: LeaveListItem) -> String {
        let reason = leave.reason.trimmingCharacters(in: .whitespacesAndNewlines)

        if !reason.isEmpty {
            return reason
        }

        return displayLeaveType(leave.leaveType)
    }

    private func remarkText(from leave: LeaveListItem) -> String {
        let daysText = formattedDays(leave.totalDays)
        let status = leave.status.uppercased()

        switch status {
        case "PENDING":
            return "\(daysText) · awaiting class teacher"

        case "APPROVED":
            if let remarks = leave.reviewRemarks,
               !remarks.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return "\(daysText) · \(remarks)"
            }
            return "\(daysText) · approved"

        case "REJECTED":
            if let remarks = leave.reviewRemarks,
               !remarks.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return "\(daysText) · \(remarks)"
            }
            return "\(daysText) · rejected"

        default:
            return daysText
        }
    }

    private func displayLeaveType(_ raw: String) -> String {
        switch raw.uppercased() {
        case "SICK":
            return "Sick Leave"
        case "CASUAL":
            return "Casual Leave"
        case "EMERGENCY":
            return "Emergency Leave"
        case "OTHER":
            return "Other Leave"
        default:
            return raw.capitalized
        }
    }

    private func formattedDays(_ value: String) -> String {
        guard let days = Double(value) else {
            return "\(value) days"
        }

        if days == 1 {
            return "1 day"
        }

        if days.rounded() == days {
            return "\(Int(days)) days"
        }

        return "\(days) days"
    }

    // MARK: - Date Helpers

    private func compactDateText(
        start: String,
        end: String
    ) -> String {
        guard
            let startDate = Self.apiDateFormatter.date(from: start),
            let endDate = Self.apiDateFormatter.date(from: end)
        else {
            return start == end ? start : "\(start)-\(end)"
        }

        if startDate == endDate {
            return Self.compactDateFormatter.string(from: startDate)
        }

        let startText = Self.compactDateFormatter.string(from: startDate)
        let endText = Self.compactDateFormatter.string(from: endDate)

        return "\(startText)-\(endText)"
    }

    private static let apiDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    private static let compactDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    // MARK: - Figma Status Colors

    private func styleForStatus(_ status: String) -> LeaveCellStyle {
        switch status {

        case "APPROVED":
            return LeaveCellStyle(
                cardBackground: UIColor.white,
                borderColor: UIColor(
                    red: 0.86,
                    green: 0.89,
                    blue: 0.94,
                    alpha: 1.0
                ),
                accentColor: UIColor(
                    red: 0.37,
                    green: 0.57,
                    blue: 0.78,
                    alpha: 1.0
                ),
                statusTextColor: UIColor(
                    red: 0.04,
                    green: 0.50,
                    blue: 0.28,
                    alpha: 1.0
                ),
                statusBackground: UIColor(
                    red: 0.78,
                    green: 0.94,
                    blue: 0.84,
                    alpha: 1.0
                )
            )

        case "REJECTED":
            return LeaveCellStyle(
                cardBackground: UIColor(
                    red: 1.0,
                    green: 0.94,
                    blue: 0.94,
                    alpha: 1.0
                ),
                borderColor: UIColor(
                    red: 1.0,
                    green: 0.55,
                    blue: 0.55,
                    alpha: 1.0
                ),
                accentColor: UIColor(
                    red: 0.96,
                    green: 0.16,
                    blue: 0.20,
                    alpha: 1.0
                ),
                statusTextColor: UIColor(
                    red: 0.75,
                    green: 0.08,
                    blue: 0.08,
                    alpha: 1.0
                ),
                statusBackground: UIColor(
                    red: 1.0,
                    green: 0.82,
                    blue: 0.84,
                    alpha: 1.0
                )
            )

        default:
            return LeaveCellStyle(
                cardBackground: UIColor(
                    red: 1.0,
                    green: 0.97,
                    blue: 0.88,
                    alpha: 1.0
                ),
                borderColor: UIColor(
                    red: 0.96,
                    green: 0.74,
                    blue: 0.35,
                    alpha: 1.0
                ),
                accentColor: UIColor(
                    red: 0.96,
                    green: 0.55,
                    blue: 0.06,
                    alpha: 1.0
                ),
                statusTextColor: UIColor(
                    red: 0.72,
                    green: 0.29,
                    blue: 0.02,
                    alpha: 1.0
                ),
                statusBackground: UIColor(
                    red: 1.0,
                    green: 0.89,
                    blue: 0.55,
                    alpha: 1.0
                )
            )
        }
    }
}

// MARK: - Cell Style Model

private struct LeaveCellStyle {
    let cardBackground: UIColor
    let borderColor: UIColor
    let accentColor: UIColor
    let statusTextColor: UIColor
    let statusBackground: UIColor
}
