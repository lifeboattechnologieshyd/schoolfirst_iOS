//
//  HomeworkDetailsTableViewCell.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 09/06/26.
//

import UIKit

class HomeworkDetailsTableViewCell: UITableViewCell {

    // MARK: - Outlets

    @IBOutlet weak var SubmitButton: UIButton!
    @IBOutlet weak var Addremarkstextview: UITextView!
    @IBOutlet weak var StatusLbl: UILabel!
    @IBOutlet weak var Description: UILabel!
    @IBOutlet weak var Homeworktitle: UILabel!
    @IBOutlet weak var Duedate: UILabel!
    @IBOutlet weak var Subject: UILabel!

    @IBOutlet weak var Containerview2: UIView!
    @IBOutlet weak var Cantainerview1: UIView!
    @IBOutlet weak var Containerview4: UIView!
    @IBOutlet weak var Containerview3: UIView!

    // MARK: - Callback

    /// Remarks may be nil or empty.
    var onSubmitTapped: ((String?) -> Void)?

    // MARK: - Data

    private var homework: StudentHomework?

    // MARK: - Date Formatters

    private lazy var apiDateFormatter: DateFormatter = {

        let formatter =
            DateFormatter()

        formatter.locale =
            Locale(
                identifier: "en_US_POSIX"
            )

        formatter.calendar =
            Calendar(
                identifier: .gregorian
            )

        formatter.timeZone =
            TimeZone(
                secondsFromGMT: 0
            )

        formatter.dateFormat =
            "yyyy-MM-dd"

        return formatter
    }()

    private lazy var displayDateFormatter: DateFormatter = {

        let formatter =
            DateFormatter()

        formatter.locale =
            Locale(
                identifier: "en_US_POSIX"
            )

        formatter.dateFormat =
            "MMM dd, yyyy"

        return formatter
    }()

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none

        setupShadow(
            for: Cantainerview1
        )

        setupShadow(
            for: Containerview2
        )

        setupShadow(
            for: Containerview3
        )

        setupShadow(
            for: Containerview4
        )

        setupStatusLabel()
        setupRemarksTextView()
        setupSubmitButton()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        updateShadowPath(
            for: Cantainerview1
        )

        updateShadowPath(
            for: Containerview2
        )

        updateShadowPath(
            for: Containerview3
        )

        updateShadowPath(
            for: Containerview4
        )
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        homework = nil
        onSubmitTapped = nil

        Homeworktitle.text = nil
        Description.text = nil
        Duedate.text = nil
        Subject.text = nil
        StatusLbl.text = nil

        StatusLbl.textColor =
            .label

        StatusLbl.textAlignment =
            .center

        StatusLbl.backgroundColor =
            .clear

        Addremarkstextview.text =
            nil

        Addremarkstextview.isEditable =
            true

        SubmitButton.isEnabled =
            true

        SubmitButton.alpha =
            1

        SubmitButton.setTitle(
            "Submit",
            for: .normal
        )

        accessibilityLabel = nil
        accessibilityValue = nil
    }

    // MARK: - UI Setup

    private func setupShadow(
        for view: UIView
    ) {

        view.layer.shadowColor =
            UIColor.lightGray.cgColor

        view.layer.shadowOpacity =
            0.4

        view.layer.shadowOffset =
            CGSize(
                width: 0,
                height: 4
            )

        view.layer.shadowRadius =
            2

        view.layer.masksToBounds =
            false
    }

    private func updateShadowPath(
        for view: UIView
    ) {

        view.layer.shadowPath =
            UIBezierPath(
                roundedRect: view.bounds,
                cornerRadius:
                    view.layer.cornerRadius
            ).cgPath
    }

    private func setupStatusLabel() {

        StatusLbl.layer.cornerRadius =
            10

        StatusLbl.textAlignment =
            .center

        StatusLbl.numberOfLines =
            1

        StatusLbl.adjustsFontSizeToFitWidth =
            true

        StatusLbl.minimumScaleFactor =
            0.8

        StatusLbl.clipsToBounds =
            true
    }

    private func setupRemarksTextView() {

        Addremarkstextview.delegate =
            self

        Addremarkstextview.layer.cornerRadius =
            10

        Addremarkstextview.layer.borderWidth =
            1

        Addremarkstextview.layer.borderColor =
            UIColor.systemGray4.cgColor

        Addremarkstextview.clipsToBounds =
            true

        Addremarkstextview.textContainerInset =
            UIEdgeInsets(
                top: 12,
                left: 10,
                bottom: 12,
                right: 10
            )

        Addremarkstextview.font =
            UIFont.systemFont(
                ofSize: 15,
                weight: .regular
            )

        Addremarkstextview.returnKeyType =
            .done
    }

    private func setupSubmitButton() {

        SubmitButton.layer.cornerRadius =
            12

        SubmitButton.clipsToBounds =
            true

        SubmitButton.addTarget(
            self,
            action: #selector(submitButtonTapped),
            for: .touchUpInside
        )
    }

    // MARK: - Submit Action

    @objc
    private func submitButtonTapped() {

        guard SubmitButton.isEnabled else {
            return
        }

        let remarks =
            Addremarkstextview.text?
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )

        /*
         Remarks are optional. An empty value is converted
         to nil before sending it to the view controller.
         */
        let optionalRemarks: String?

        if let remarks = remarks,
           !remarks.isEmpty {

            optionalRemarks =
                remarks

        } else {

            optionalRemarks =
                nil
        }

        onSubmitTapped?(
            optionalRemarks
        )
    }

    // MARK: - Submission State

    func setSubmitting(
        _ submitting: Bool
    ) {

        SubmitButton.isEnabled =
            !submitting

        SubmitButton.alpha =
            submitting
            ? 0.65
            : 1

        SubmitButton.setTitle(
            submitting
            ? "Submitting..."
            : "Submit",
            for: .normal
        )

        Addremarkstextview.isEditable =
            !submitting
    }

    // MARK: - Configure API Data

    func configure(
        with homework: StudentHomework
    ) {

        self.homework =
            homework

        Homeworktitle.text =
            homework.title

        Description.text =
            homework.description

        Subject.text =
            homework.subject.name
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
                .capitalized

        Duedate.text =
            formattedDueDate(
                homework.dueDate
            )

        configureStatus(
            homework.submission.status,
            dueDate: homework.dueDate
        )

        configureSubmissionControls(
            status: homework.submission.status
        )

        configureAccessibility(
            with: homework
        )

        print(
            "✅ Homework details cell configured"
        )

        print(
            "Title: \(homework.title)"
        )

        print(
            "Description: \(homework.description)"
        )

        print(
            "Assigned date: \(homework.assignedDate)"
        )

        print(
            "Due date: \(homework.dueDate)"
        )

        print(
            "Subject: \(homework.subject.name)"
        )

        print(
            "Teacher: \(homework.teacher.name)"
        )

        print(
            "Publish status: \(homework.status)"
        )

        print(
            "Submission status: \(homework.submission.status)"
        )

        print(
            "Submitted at: \(homework.submission.submittedAt ?? "N/A")"
        )

        print(
            "Teacher remarks: \(homework.submission.teacherRemarks ?? "N/A")"
        )
    }

    // MARK: - Submission Controls

    private func configureSubmissionControls(
        status: String
    ) {

        let normalizedStatus =
            status
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
                .uppercased()

        let isAlreadySubmitted =
            normalizedStatus == "SUBMITTED"
            || normalizedStatus == "COMPLETED"
            || normalizedStatus == "APPROVED"

        SubmitButton.isEnabled =
            !isAlreadySubmitted

        SubmitButton.alpha =
            isAlreadySubmitted
            ? 0.6
            : 1

        SubmitButton.setTitle(
            isAlreadySubmitted
            ? "Submitted"
            : "Submit",
            for: .normal
        )

        Addremarkstextview.isEditable =
            !isAlreadySubmitted
    }

    // MARK: - Configure Status

    private func configureStatus(
        _ status: String,
        dueDate: String
    ) {

        let normalizedStatus =
            status
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
                .uppercased()

        switch normalizedStatus {

        case "COMPLETED",
             "SUBMITTED",
             "APPROVED":

            applyStatusStyle(
                text:
                    formattedStatus(
                        normalizedStatus
                    ),
                color:
                    .systemGreen
            )

        case "REJECTED":

            applyStatusStyle(
                text: "Rejected",
                color: .systemRed
            )

        case "PENDING":

            if isOverdue(
                dueDate
            ) {

                applyStatusStyle(
                    text: "Overdue",
                    color: .systemRed
                )

            } else {

                applyStatusStyle(
                    text: "Pending",
                    color: .systemOrange
                )
            }

        default:

            let displayStatus =
                normalizedStatus.isEmpty
                ? "Unknown"
                : formattedStatus(
                    normalizedStatus
                )

            applyStatusStyle(
                text: displayStatus,
                color: .systemOrange
            )
        }
    }

    private func applyStatusStyle(
        text: String,
        color: UIColor
    ) {

        StatusLbl.text =
            text

        StatusLbl.textAlignment =
            .center

        StatusLbl.textColor =
            color

        StatusLbl.backgroundColor =
            color.withAlphaComponent(
                0.15
            )
    }

    // MARK: - Date Formatting

    private func formattedDueDate(
        _ dateString: String
    ) -> String {

        guard let date =
                apiDateFormatter.date(
                    from: dateString
                ) else {

            return "Due: \(dateString)"
        }

        let displayDate =
            displayDateFormatter.string(
                from: date
            )

        return "Due: \(displayDate)"
    }

    private func isOverdue(
        _ dateString: String
    ) -> Bool {

        guard let dueDate =
                apiDateFormatter.date(
                    from: dateString
                ) else {

            return false
        }

        var calendar =
            Calendar(
                identifier: .gregorian
            )

        calendar.timeZone =
            TimeZone.current

        let today =
            calendar.startOfDay(
                for: Date()
            )

        let normalizedDueDate =
            calendar.startOfDay(
                for: dueDate
            )

        return normalizedDueDate < today
    }

    private func formattedStatus(
        _ status: String
    ) -> String {

        return status
            .lowercased()
            .replacingOccurrences(
                of: "_",
                with: " "
            )
            .capitalized
    }

    // MARK: - Accessibility

    private func configureAccessibility(
        with homework: StudentHomework
    ) {

        isAccessibilityElement =
            true

        accessibilityLabel =
            homework.title

        accessibilityValue =
            """
            Subject \(homework.subject.name), \
            Teacher \(homework.teacher.name), \
            Due date \(homework.dueDate), \
            Status \(homework.submission.status)
            """
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
}

// MARK: - UITextViewDelegate

extension HomeworkDetailsTableViewCell:
    UITextViewDelegate {

    func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText text: String
    ) -> Bool {

        if text == "\n" {

            textView.resignFirstResponder()
            return false
        }

        return true
    }
}
