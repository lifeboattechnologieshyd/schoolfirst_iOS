//
//  HomeworkDetailsTableViewCell.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 09/06/26.
//

import UIKit

class HomeworkDetailsTableViewCell: UITableViewCell {

    // MARK: - Outlets

    @IBOutlet weak var Descriptionbackgroundview: UIView!
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

    /// Bottom pin: Description → Descriptionbackgroundview (removes empty space)
    private var descriptionBottomConstraint: NSLayoutConstraint?
    private var didSetupDynamicHeight = false

    /// ✅ Keeps submitted remark so it always stays visible in text view
    private var savedRemarks: String?

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

        // ✅ Dynamic height — empty space remove cheyadaniki
        setupDynamicHeightForDescription()
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

        // Accurate multiline height calculation
        if Description.bounds.width > 0 {
            Description.preferredMaxLayoutWidth = Description.bounds.width
        }
    }

    override func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority
    ) -> CGSize {

        if Description.bounds.width > 0 {
            Description.preferredMaxLayoutWidth = Description.bounds.width
        } else {
            let horizontalPadding: CGFloat = 32
            Description.preferredMaxLayoutWidth = targetSize.width - horizontalPadding
        }

        return super.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: horizontalFittingPriority,
            verticalFittingPriority: verticalFittingPriority
        )
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        homework = nil
        onSubmitTapped = nil
        savedRemarks = nil

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

        Addremarkstextview.isSelectable =
            true

        Addremarkstextview.isUserInteractionEnabled =
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

    // MARK: - Remarks Persistence & Display

    func persistAndShowRemarks(_ remarks: String?, homeworkId: String? = nil) {
        let id = homeworkId ?? homework?.id
        let trimmed = remarks?.trimmingCharacters(in: .whitespacesAndNewlines)

        if let trimmed = trimmed, !trimmed.isEmpty {
            savedRemarks = trimmed
            Addremarkstextview.text = trimmed
            if let id = id, !id.isEmpty {
                UserDefaults.standard.set(trimmed, forKey: "homework_remark_\(id)")
            }
        } else if let id = id, !id.isEmpty,
                  let storedRemark = UserDefaults.standard.string(forKey: "homework_remark_\(id)"),
                  !storedRemark.isEmpty {
            savedRemarks = storedRemark
            Addremarkstextview.text = storedRemark
        }
    }

    // MARK: - UI Setup

    /// ✅ FIX: Description + Descriptionbackgroundview dynamic height
    /// Empty space completely remove avuthundi — text size ki thagga height vastundi
    private func setupDynamicHeightForDescription() {
        guard !didSetupDynamicHeight else { return }
        didSetupDynamicHeight = true

        // 1. Multiline label
        Description.numberOfLines = 0
        Description.lineBreakMode = .byWordWrapping

        // 2. Content hugging — view ni content size ki shrink cheyadaniki
        Description.setContentHuggingPriority(.required, for: .vertical)
        Description.setContentCompressionResistancePriority(.required, for: .vertical)

        Descriptionbackgroundview.setContentHuggingPriority(UILayoutPriority(999), for: .vertical)
        Descriptionbackgroundview.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)

        if let title = Homeworktitle {
            title.numberOfLines = 0
            title.setContentHuggingPriority(.required, for: .vertical)
        }

        // 3. Storyboard fixed HEIGHT constraints ni fully deactivate cheyandi
        deactivateHeightConstraints(for: Description)
        deactivateHeightConstraints(for: Descriptionbackgroundview)

        // Superview lo unna height constraints kuda remove
        if let parent = Descriptionbackgroundview.superview {
            parent.constraints.forEach { constraint in
                let isBGHeight =
                    (constraint.firstItem as? UIView == Descriptionbackgroundview && constraint.firstAttribute == .height) ||
                    (constraint.secondItem as? UIView == Descriptionbackgroundview && constraint.secondAttribute == .height)

                let isDescHeight =
                    (constraint.firstItem as? UIView == Description && constraint.firstAttribute == .height) ||
                    (constraint.secondItem as? UIView == Description && constraint.secondAttribute == .height)

                if isBGHeight || isDescHeight {
                    constraint.isActive = false
                }
            }
        }

        contentView.constraints.forEach { constraint in
            let isBGHeight =
                (constraint.firstItem as? UIView == Descriptionbackgroundview && constraint.firstAttribute == .height) ||
                (constraint.secondItem as? UIView == Descriptionbackgroundview && constraint.secondAttribute == .height)
            if isBGHeight {
                constraint.isActive = false
            }
        }

        // 4. Description bottom ni background view bottom ki pin cheyandi
        //    → container content tharwatha ne end avuthundi (no empty space)
        if descriptionBottomConstraint == nil {
            let bottomPin = Description.bottomAnchor.constraint(
                equalTo: Descriptionbackgroundview.bottomAnchor,
                constant: -16
            )
            bottomPin.priority = UILayoutPriority(999)
            bottomPin.isActive = true
            descriptionBottomConstraint = bottomPin
        }
    }

    private func deactivateHeightConstraints(for view: UIView) {
        view.constraints.forEach { constraint in
            // Only constant height constraints (not aspect ratio etc.)
            if constraint.firstAttribute == .height &&
                constraint.secondItem == nil {
                constraint.isActive = false
            }
        }
    }

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

        let optionalRemarks: String?

        if let remarks = remarks,
           !remarks.isEmpty {

            optionalRemarks =
                remarks

        } else {

            optionalRemarks =
                nil
        }

        // ✅ Save remark locally BEFORE callback so it never disappears
        savedRemarks = optionalRemarks
        if let optionalRemarks = optionalRemarks {
            persistAndShowRemarks(optionalRemarks)
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

        // While submitting keep "Submitting..."; when done VC should call lockAfterSubmission()
        if submitting {
            SubmitButton.setTitle(
                "Submitting...",
                for: .normal
            )
        }

        Addremarkstextview.isEditable =
            !submitting
    }

    // ✅ Call this from ViewController AFTER submit API success
    // Button title → "Submitted"
    // Remark stays visible forever in text view (read-only)
    func lockAfterSubmission() {

        let remarksToShow =
            savedRemarks
            ?? Addremarkstextview.text?
                .trimmingCharacters(in: .whitespacesAndNewlines)

        if let remarksToShow = remarksToShow, !remarksToShow.isEmpty {
            persistAndShowRemarks(remarksToShow)
        }

        SubmitButton.isEnabled =
            false

        SubmitButton.alpha =
            0.6

        SubmitButton.setTitle(
            "Submitted",
            for: .normal
        )

        // Remark always visible, but not editable
        Addremarkstextview.isEditable =
            false

        Addremarkstextview.isSelectable =
            true

        Addremarkstextview.isUserInteractionEnabled =
            true
    }

    // MARK: - Configure API Data

    func configure(
        with homework: StudentHomework
    ) {

        self.homework =
            homework

        Homeworktitle.text =
            homework.title

        // ✅ Description text + relayout for dynamic height
        Description.text =
            homework.description

        Description.invalidateIntrinsicContentSize()
        Descriptionbackgroundview.invalidateIntrinsicContentSize()

        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()

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

        // ✅ Restore saved remarks from disk/memory if exists
        persistAndShowRemarks(nil, homeworkId: homework.id)

        configureAccessibility(
            with: homework
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

        // ✅ Remarks always visible; editable only if NOT submitted
        Addremarkstextview.isEditable =
            !isAlreadySubmitted

        Addremarkstextview.isSelectable =
            true

        Addremarkstextview.isUserInteractionEnabled =
            true
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
