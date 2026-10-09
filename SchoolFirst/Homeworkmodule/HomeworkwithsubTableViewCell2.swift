//
//  HomeworkwithsubTableViewCell2.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 09/06/26.
//

import UIKit

class HomeworkwithsubTableViewCell2: UITableViewCell {

    // MARK: - Outlets

    @IBOutlet weak var Backgrounview: UIView!
    @IBOutlet weak var MarkCompletebutton: UIButton!
    @IBOutlet weak var Teachername: UILabel!
    @IBOutlet weak var Duedate: UILabel!
    @IBOutlet weak var Description: UILabel!
    @IBOutlet weak var Homeworktitle: UILabel!
    @IBOutlet weak var PrioritbadgeLabel: UILabel!
    @IBOutlet weak var Subject: UILabel!
    @IBOutlet weak var SubjectImage: UIImageView!
    @IBOutlet weak var ImageBackgroundview: UIView!
    @IBOutlet weak var ContainerView: UIView!

    // MARK: - Callback

    var onViewDetailsTapped: (() -> Void)?
    var onMarkCompleteTapped: (() -> Void)?

    // MARK: - View Details Button

    private lazy var viewDetailsButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("View Details", for: .normal)
        button.setTitleColor(
            UIColor(red: 26.0/255.0, green: 53.0/255.0, blue: 103.0/255.0, alpha: 1.0),
            for: .normal
        )
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        button.isHidden = true
        return button
    }()

    /// Constraints we create so we can turn them on/off cleanly
    private var dynamicConstraints: [NSLayoutConstraint] = []

    // MARK: - Date Formatters

    private lazy var apiDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private lazy var displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter
    }()

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none

        setupDynamicHeight()
        setupContainerView()
        setupBadgeLabel()
        setupImageBackground()
        setupViewDetailsButton()
        setupMarkCompleteButton()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // Multi-line label needs an explicit width to compute height
        let padding: CGFloat = 40
        let w = max(ContainerView.bounds.width - padding, 0)
        if w > 0 {
            if Description.preferredMaxLayoutWidth != w {
                Description.preferredMaxLayoutWidth = w
            }
            if Homeworktitle.preferredMaxLayoutWidth != w {
                Homeworktitle.preferredMaxLayoutWidth = w
            }
        }

        ContainerView.layer.shadowPath =
            UIBezierPath(roundedRect: ContainerView.bounds, cornerRadius: 12).cgPath
    }

    override func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority
    ) -> CGSize {

        let padding: CGFloat = 40
        let width = targetSize.width > 0 ? targetSize.width : bounds.width
        let w = max(width - padding, 0)
        Description.preferredMaxLayoutWidth = w
        Homeworktitle.preferredMaxLayoutWidth = w

        return super.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: horizontalFittingPriority,
            verticalFittingPriority: .fittingSizeLevel
        )
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        onViewDetailsTapped = nil
        onMarkCompleteTapped = nil

        Homeworktitle.text = nil
        Description.text = nil
        Duedate.text = nil
        Teachername.text = nil
        Subject.text = nil
        PrioritbadgeLabel.text = nil
        SubjectImage.image = nil

        // Reset button visibility WITHOUT leaving empty layout space
        setMarkCompleteVisible(true)
        viewDetailsButton.isHidden = true

        PrioritbadgeLabel.backgroundColor = .clear
        PrioritbadgeLabel.textColor = .label

        Subject.textColor = .label
        SubjectImage.tintColor = nil

        ImageBackgroundview.backgroundColor = .clear
    }

    // MARK: - UI Setup

    private func setupDynamicHeight() {

        // 1) Labels must be allowed to grow with API text
        Description.numberOfLines = 0
        Description.lineBreakMode = .byWordWrapping
        Description.setContentHuggingPriority(.required, for: .vertical)
        Description.setContentCompressionResistancePriority(.required, for: .vertical)

        Homeworktitle.numberOfLines = 0
        Homeworktitle.setContentHuggingPriority(.required, for: .vertical)
        Homeworktitle.setContentCompressionResistancePriority(.required, for: .vertical)

        Duedate.setContentHuggingPriority(.required, for: .vertical)
        Teachername.setContentHuggingPriority(.required, for: .vertical)
        MarkCompletebutton.setContentHuggingPriority(.required, for: .vertical)

        // 2) Kill fixed height constraints (root cause of tall empty cards)
        deactivateHeightConstraints(on: Description)
        deactivateHeightConstraints(on: Homeworktitle)
        deactivateHeightConstraints(on: Backgrounview)
        deactivateHeightConstraints(on: ContainerView)
        deactivateHeightConstraints(on: contentView)
        deactivateHeightConstraintsReferencing(Backgrounview)
        deactivateHeightConstraintsReferencing(ContainerView)
        deactivateHeightConstraintsReferencing(Description)

        // 3) Kill LARGE vertical spacing constraints inside the card
        //    (Storyboard spacers that create the big empty gap)
        compressLargeVerticalSpacings(in: ContainerView)
        compressLargeVerticalSpacings(in: Backgrounview)
        compressLargeVerticalSpacings(in: contentView)

        // 4) Build a TIGHT bottom chain in code so the card always hugs content:
        //    Description → DueDate → Button row → Container bottom
        //    (priority 999 so we don't fight required IB constraints to the point of crash)
        NSLayoutConstraint.deactivate(dynamicConstraints)
        dynamicConstraints.removeAll()

        let c1 = Duedate.topAnchor.constraint(equalTo: Description.bottomAnchor, constant: 10)
        let c2 = MarkCompletebutton.topAnchor.constraint(equalTo: Duedate.bottomAnchor, constant: 12)
        let c3 = MarkCompletebutton.bottomAnchor.constraint(equalTo: ContainerView.bottomAnchor, constant: -12)

        // Keep Teachername on the same row as Duedate vertically
        let c4 = Teachername.centerYAnchor.constraint(equalTo: Duedate.centerYAnchor)

        [c1, c2, c3, c4].forEach { $0.priority = UILayoutPriority(999) }

        dynamicConstraints = [c1, c2, c3, c4]
        NSLayoutConstraint.activate(dynamicConstraints)

        // If Backgrounview wraps ContainerView, hug it too
        if Backgrounview !== ContainerView {
            let bg = ContainerView.bottomAnchor.constraint(equalTo: Backgrounview.bottomAnchor, constant: 0)
            bg.priority = UILayoutPriority(999)
            bg.isActive = true
            dynamicConstraints.append(bg)

            let bgTop = ContainerView.topAnchor.constraint(equalTo: Backgrounview.topAnchor, constant: 0)
            bgTop.priority = UILayoutPriority(999)
            bgTop.isActive = true
            dynamicConstraints.append(bgTop)
        }
    }

    /// Hide / show Mark Complete without leaving blank layout space
    private func setMarkCompleteVisible(_ visible: Bool) {
        MarkCompletebutton.isHidden = !visible
        MarkCompletebutton.alpha = visible ? 1 : 0
        MarkCompletebutton.isUserInteractionEnabled = visible

        // Collapse height when hidden so it cannot reserve empty space
        MarkCompletebutton.constraints.forEach { c in
            if c.firstAttribute == .height && c.secondItem == nil {
                c.isActive = false
            }
        }
        if !visible {
            let zeroH = MarkCompletebutton.heightAnchor.constraint(equalToConstant: 0)
            zeroH.priority = UILayoutPriority(999)
            zeroH.isActive = true
        } else {
            let h = MarkCompletebutton.heightAnchor.constraint(equalToConstant: 40)
            h.priority = UILayoutPriority(999)
            h.isActive = true
        }
    }

    private func deactivateHeightConstraints(on view: UIView?) {
        guard let view = view else { return }
        view.constraints.forEach { c in
            if c.firstAttribute == .height || c.secondAttribute == .height {
                c.isActive = false
            }
        }
    }

    private func deactivateHeightConstraintsReferencing(_ view: UIView?) {
        guard let view = view else { return }
        var parents: [UIView] = []
        var p = view.superview
        while let v = p {
            parents.append(v)
            p = v.superview
        }
        for parent in parents {
            parent.constraints.forEach { c in
                let involves =
                    (c.firstItem as? UIView) == view ||
                    (c.secondItem as? UIView) == view
                let isH = c.firstAttribute == .height || c.secondAttribute == .height
                if involves && isH {
                    c.isActive = false
                }
            }
        }
    }

    /// Reduces absurdly large vertical gaps from Storyboard (the empty white area)
    private func compressLargeVerticalSpacings(in root: UIView?) {
        guard let root = root else { return }

        var views: [UIView] = [root]
        views.append(contentsOf: root.subviews)

        for v in views {
            v.constraints.forEach { c in
                let vertical =
                    c.firstAttribute == .top ||
                    c.firstAttribute == .bottom ||
                    c.firstAttribute == .centerY ||
                    c.secondAttribute == .top ||
                    c.secondAttribute == .bottom ||
                    c.secondAttribute == .centerY

                // Only touch pure spacing constraints with a large constant
                if vertical, c.secondItem != nil, abs(c.constant) > 18 {
                    // Keep a small readable gap instead of 40–80pt empty holes
                    if c.constant > 18 { c.constant = 12 }
                    if c.constant < -18 { c.constant = -12 }
                }
            }

            // Constraints live on the parent, so also scan superview constraints
            v.superview?.constraints.forEach { c in
                let involves =
                    (c.firstItem as? UIView) == v ||
                    (c.secondItem as? UIView) == v
                let vertical =
                    c.firstAttribute == .top ||
                    c.firstAttribute == .bottom ||
                    c.secondAttribute == .top ||
                    c.secondAttribute == .bottom

                if involves, vertical, c.secondItem != nil, abs(c.constant) > 18 {
                    if c.constant > 18 { c.constant = 12 }
                    if c.constant < -18 { c.constant = -12 }
                }
            }
        }
    }

    private func setupContainerView() {
        ContainerView.layer.cornerRadius = 12
        ContainerView.layer.shadowColor = UIColor.lightGray.cgColor
        ContainerView.layer.shadowOpacity = 0.2
        ContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        ContainerView.layer.shadowRadius = 4
        ContainerView.layer.masksToBounds = false
    }

    private func setupBadgeLabel() {
        PrioritbadgeLabel.layer.cornerRadius = 10
        PrioritbadgeLabel.clipsToBounds = true
    }

    private func setupImageBackground() {
        ImageBackgroundview.layer.cornerRadius = 10
        ImageBackgroundview.clipsToBounds = true
    }

    private func setupViewDetailsButton() {
        ContainerView.addSubview(viewDetailsButton)

        viewDetailsButton.addTarget(
            self,
            action: #selector(viewDetailsTapped),
            for: .touchUpInside
        )

        NSLayoutConstraint.activate([
            // Sit on the same row as Mark Complete
            viewDetailsButton.centerYAnchor.constraint(
                equalTo: MarkCompletebutton.centerYAnchor
            ),
            viewDetailsButton.trailingAnchor.constraint(
                equalTo: ContainerView.trailingAnchor,
                constant: -20
            ),
            viewDetailsButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }

    private func setupMarkCompleteButton() {
        MarkCompletebutton.addTarget(
            self,
            action: #selector(markCompleteButtonTapped),
            for: .touchUpInside
        )
    }

    // MARK: - Actions

    @objc
    private func viewDetailsTapped() {
        onViewDetailsTapped?()
    }

    @objc
    private func markCompleteButtonTapped() {
        onMarkCompleteTapped?()
    }

    // MARK: - Configure API Data

    func configure(with homework: StudentHomework) {

        // Default: show mark-complete, hide view-details
        setMarkCompleteVisible(true)
        viewDetailsButton.isHidden = true

        Homeworktitle.text = homework.title
        Description.text = homework.description
        Duedate.text = formattedDueDate(homework.dueDate)
        Teachername.text = homework.teacher.name
        Subject.text = homework.subject.name.capitalized

        configureSubjectImage(subjectName: homework.subject.name)

        configureSubmissionStatus(
            homework.submission.status,
            dueDate: homework.dueDate
        )

        // Force the cell to re-measure after text + visibility changes
        setNeedsLayout()
        layoutIfNeeded()
        invalidateIntrinsicContentSize()
    }

    // MARK: - Submission Status

    private func configureSubmissionStatus(_ status: String, dueDate: String) {

        let normalizedStatus = status
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()

        switch normalizedStatus {

        case "COMPLETED", "SUBMITTED", "APPROVED":
            applyStyle(color: .systemGreen, text: formattedStatus(normalizedStatus))
            // Submitted → show View Details, collapse Mark Complete (no empty space)
            setMarkCompleteVisible(false)
            viewDetailsButton.isHidden = false

        case "REJECTED":
            applyStyle(color: .systemRed, text: "Rejected")
            setMarkCompleteVisible(true)
            viewDetailsButton.isHidden = true

        case "PENDING":
            if isOverdue(dueDate) {
                applyStyle(color: .systemRed, text: "Overdue")
            } else {
                applyStyle(color: .systemOrange, text: "Pending")
            }
            setMarkCompleteVisible(true)
            viewDetailsButton.isHidden = true

        default:
            applyStyle(color: .systemOrange, text: formattedStatus(normalizedStatus))
            setMarkCompleteVisible(true)
            viewDetailsButton.isHidden = true
        }
    }

    // MARK: - Subject Image

    private func configureSubjectImage(subjectName: String) {

        let normalizedSubject = subjectName
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        let imageName: String

        switch normalizedSubject {
        case "math", "maths", "mathematics":
            imageName = "Mathsicon"
        case "science", "general science":
            imageName = "ic_science"
        case "history":
            imageName = "ic_history"
        case "english":
            imageName = "ic_english"
        case "social", "social studies", "social science":
            imageName = "ic_social"
        case "computer", "computers", "computer science":
            imageName = "ic_computer"
        case "physics":
            imageName = "ic_physics"
        case "chemistry":
            imageName = "ic_chemistry"
        case "biology":
            imageName = "ic_biology"
        case "geography":
            imageName = "ic_geography"
        default:
            SubjectImage.image = UIImage(systemName: "book.closed.fill")
            return
        }

        SubjectImage.image = UIImage(named: imageName)
            ?? UIImage(systemName: "book.closed.fill")
    }

    // MARK: - Style

    private func applyStyle(color: UIColor, text: String) {
        PrioritbadgeLabel.text = text
        PrioritbadgeLabel.backgroundColor = color.withAlphaComponent(0.15)
        PrioritbadgeLabel.textColor = color
        Subject.textColor = color
        SubjectImage.tintColor = color
        ImageBackgroundview.backgroundColor = color.withAlphaComponent(0.15)
    }

    // MARK: - Date Helpers

    private func formattedDueDate(_ dateString: String) -> String {
        guard let date = apiDateFormatter.date(from: dateString) else {
            return "Due: \(dateString)"
        }
        return "Due: \(displayDateFormatter.string(from: date))"
    }

    private func isOverdue(_ dateString: String) -> Bool {
        guard let dueDate = apiDateFormatter.date(from: dateString) else {
            return false
        }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let normalizedDueDate = calendar.startOfDay(for: dueDate)
        return normalizedDueDate < today
    }

    private func formattedStatus(_ status: String) -> String {
        return status
            .lowercased()
            .replacingOccurrences(of: "_", with: " ")
            .capitalized
    }
}
