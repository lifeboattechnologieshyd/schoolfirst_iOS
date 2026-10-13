//
//  FeedbackoverviewVCTBLVWCell2.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 12/10/26.
//

import UIKit

class FeedbackoverviewVCTBLVWCell2: UITableViewCell {

    @IBOutlet weak var createddateandcatogeryandgradelabel: UILabel!
    @IBOutlet weak var feedbackstatus: UILabel!
    @IBOutlet weak var feedbackmessage: UILabel!
    @IBOutlet weak var feedbacksubject: UILabel!

    // MARK: - Callback
    var onStatusTapped: ((String) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none
        contentView.isUserInteractionEnabled = true

        feedbackstatus.layer.cornerRadius = 6
        feedbackstatus.clipsToBounds = true
        feedbackstatus.textAlignment = .center

        // Enable tap on status label
        feedbackstatus.isUserInteractionEnabled = true

        // Remove any existing gesture recognizers to avoid duplicates on reuse
        feedbackstatus.gestureRecognizers?.forEach { feedbackstatus.removeGestureRecognizer($0) }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(statusLabelTapped))
        tapGesture.cancelsTouchesInView = false
        feedbackstatus.addGestureRecognizer(tapGesture)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: - Status Tap Handler
    @objc private func statusLabelTapped() {
        guard let statusText = feedbackstatus.text else {
            print("⚠️ statusLabelTapped — feedbackstatus.text is nil")
            return
        }
        print("👆 Status label tapped:", statusText)
        onStatusTapped?(statusText)
    }

    // MARK: - Configure API Data
    func configure(with feedback: Feedback) {

        // Subject
        feedbacksubject.text = feedback.subject

        // Feedback message
        feedbackmessage.text = feedback.message

        // Example:
        // Transport • Arjun Reddy • 13 Oct 2026
        let formattedDate = formatDate(feedback.createdAt)

        createddateandcatogeryandgradelabel.text =
            "\(feedback.category.name) • \(feedback.student.name) • \(formattedDate)"

        // Status configuration
        configureStatus(feedback.status)
    }

    // MARK: - Status UI
    private func configureStatus(_ status: String) {

        let statusValue = status.uppercased()

        switch statusValue {

        case "SUBMITTED", "PENDING":
            feedbackstatus.text = "Pending"
            feedbackstatus.textColor = UIColor(
                red: 0.85,
                green: 0.52,
                blue: 0.05,
                alpha: 1.0
            )
            feedbackstatus.backgroundColor = UIColor(
                red: 1.0,
                green: 0.95,
                blue: 0.85,
                alpha: 1.0
            )

        case "IN_REVIEW", "IN REVIEW":
            feedbackstatus.text = "In Review"
            feedbackstatus.textColor = UIColor(
                red: 0.25,
                green: 0.47,
                blue: 0.95,
                alpha: 1.0
            )
            feedbackstatus.backgroundColor = UIColor(
                red: 0.90,
                green: 0.93,
                blue: 1.0,
                alpha: 1.0
            )

        case "RESOLVED":
            feedbackstatus.text = "Resolved"
            feedbackstatus.textColor = UIColor(
                red: 0.15,
                green: 0.65,
                blue: 0.30,
                alpha: 1.0
            )
            feedbackstatus.backgroundColor = UIColor(
                red: 0.88,
                green: 0.97,
                blue: 0.90,
                alpha: 1.0
            )

        default:
            feedbackstatus.text = status.capitalized
            feedbackstatus.textColor = .darkGray
            feedbackstatus.backgroundColor = UIColor(
                red: 0.94,
                green: 0.94,
                blue: 0.94,
                alpha: 1.0
            )
        }
    }

    // MARK: - API Date Formatting
    private func formatDate(_ dateString: String) -> String {

        let inputFormatter = ISO8601DateFormatter()
        inputFormatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]

        guard let date = inputFormatter.date(from: dateString) else {
            return dateString
        }

        let outputFormatter = DateFormatter()
        outputFormatter.locale = Locale(identifier: "en_US_POSIX")
        outputFormatter.dateFormat = "dd MMM yyyy"

        return outputFormatter.string(from: date)
    }
}
