//
//  FeedbackoverviewVCTBLVWCell2.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 12/10/26.
//

import UIKit

class FeedbackoverviewVCTBLVWCell2: UITableViewCell {

    @IBOutlet weak var cantainerview: UIView!
    @IBOutlet weak var createddateandcatogeryandgradelabel: UILabel!
    @IBOutlet weak var feedbackstatus: UILabel!
    @IBOutlet weak var feedbackmessage: UILabel!
    @IBOutlet weak var feedbacksubject: UILabel!

    // MARK: - Callback
    var onStatusTapped: ((String) -> Void)?

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none
        contentView.isUserInteractionEnabled = true

        // ── Status label ──
        feedbackstatus.layer.cornerRadius = 6
        feedbackstatus.clipsToBounds = true
        feedbackstatus.textAlignment = .center
        feedbackstatus.isUserInteractionEnabled = true
        feedbackstatus.gestureRecognizers?.forEach { feedbackstatus.removeGestureRecognizer($0) }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(statusLabelTapped))
        tapGesture.cancelsTouchesInView = false
        feedbackstatus.addGestureRecognizer(tapGesture)

        // ── Subject label – dynamic height ──
        feedbacksubject.numberOfLines = 0
        feedbacksubject.lineBreakMode = .byWordWrapping
        feedbacksubject.setContentHuggingPriority(.required, for: .vertical)          // ✅
        feedbacksubject.setContentCompressionResistancePriority(.required, for: .vertical) // ✅

        // ── Message label – dynamic height ──
        feedbackmessage.numberOfLines = 0
        feedbackmessage.lineBreakMode = .byWordWrapping
        feedbackmessage.setContentHuggingPriority(.required, for: .vertical)          // ✅
        feedbackmessage.setContentCompressionResistancePriority(.required, for: .vertical) // ✅

        // ── Container view – remove any fixed-height constraint from IB ──
        cantainerview.clipsToBounds = true
        removeFixedHeightConstraints(from: cantainerview)                              // ✅

        // ── Minimum cell height (never collapses to 0) ──
        let minHeight = contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 108)
        minHeight.priority = UILayoutPriority(999)
        minHeight.isActive = true
    }

    // MARK: - Layout – critical for multi-line label sizing
    override func layoutSubviews() {
        super.layoutSubviews()

        // preferredMaxLayoutWidth tells Auto Layout how wide the label
        // actually is so it can compute the correct multi-line height.
        let subjectWidth = feedbacksubject.bounds.width
        let messageWidth = feedbackmessage.bounds.width

        if subjectWidth > 0 && feedbacksubject.preferredMaxLayoutWidth != subjectWidth {
            feedbacksubject.preferredMaxLayoutWidth = subjectWidth                     // ✅
        }
        if messageWidth > 0 && feedbackmessage.preferredMaxLayoutWidth != messageWidth {
            feedbackmessage.preferredMaxLayoutWidth = messageWidth                     // ✅
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: - Status Tap Handler
    @objc private func statusLabelTapped() {
        guard let statusText = feedbackstatus.text else { return }
        onStatusTapped?(statusText)
    }

    // MARK: - Configure API Data
    func configure(with feedback: Feedback) {
        feedbacksubject.text = feedback.subject
        feedbackmessage.text = feedback.message

        let formattedDate = formatDate(feedback.createdAt)
        createddateandcatogeryandgradelabel.text =
            "\(feedback.category.name) • \(feedback.student.name) • \(formattedDate)"

        configureStatus(feedback.status)

        // Force the cell to recalculate its height after new text is set
        setNeedsLayout()                                                               // ✅
        layoutIfNeeded()                                                               // ✅
    }

    // MARK: - Status UI
    private func configureStatus(_ status: String) {
        let statusValue = status.uppercased()

        switch statusValue {
        case "SUBMITTED", "PENDING":
            feedbackstatus.text = "Pending"
            feedbackstatus.textColor = UIColor(red: 0.85, green: 0.52, blue: 0.05, alpha: 1.0)
            feedbackstatus.backgroundColor = UIColor(red: 1.0, green: 0.95, blue: 0.85, alpha: 1.0)

        case "IN_REVIEW", "IN REVIEW":
            feedbackstatus.text = "In Review"
            feedbackstatus.textColor = UIColor(red: 0.25, green: 0.47, blue: 0.95, alpha: 1.0)
            feedbackstatus.backgroundColor = UIColor(red: 0.90, green: 0.93, blue: 1.0, alpha: 1.0)

        case "RESOLVED":
            feedbackstatus.text = "Resolved"
            feedbackstatus.textColor = UIColor(red: 0.15, green: 0.65, blue: 0.30, alpha: 1.0)
            feedbackstatus.backgroundColor = UIColor(red: 0.88, green: 0.97, blue: 0.90, alpha: 1.0)

        default:
            feedbackstatus.text = status.capitalized
            feedbackstatus.textColor = .darkGray
            feedbackstatus.backgroundColor = UIColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1.0)
        }
    }

    // MARK: - API Date Formatting
    private func formatDate(_ dateString: String) -> String {
        let inputFormatter = ISO8601DateFormatter()
        inputFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let date = inputFormatter.date(from: dateString) else { return dateString }

        let outputFormatter = DateFormatter()
        outputFormatter.locale = Locale(identifier: "en_US_POSIX")
        outputFormatter.dateFormat = "dd MMM yyyy"

        return outputFormatter.string(from: date)
    }

    // MARK: - Helper: Strip fixed-height constraints from container
    private func removeFixedHeightConstraints(from view: UIView) {
        for constraint in view.constraints where constraint.firstAttribute == .height
            && constraint.relation == .equal {
            // Only remove hard-coded height; keep ≥ / ≤ constraints
            constraint.isActive = false                                                // ✅
        }
    }
}
