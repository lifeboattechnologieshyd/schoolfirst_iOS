//
//  FeedbackinreviewTBLVWCell.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 12/10/26.
//

import UIKit

class FeedbackinreviewTBLVWCell: UITableViewCell {

    @IBOutlet weak var view3: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var View1: UIView!
    @IBOutlet weak var FathernamefirsttwolettersLabel: UILabel!
    @IBOutlet weak var FathernameLabel: UILabel!   // ✅ FIXED: Must be UILabel (not NSLayoutConstraint)
    @IBOutlet weak var Feedbackmessagebackgroundview: UIView!
    @IBOutlet weak var ResponsemessageLabel: UILabel!
    @IBOutlet weak var Responsedatelabel: UILabel!
    @IBOutlet weak var Catogerylabel: UILabel!
    @IBOutlet weak var submitparentandgradeanddatelabel: UILabel!
    @IBOutlet weak var Feedbackmessagelabel: UILabel!
    @IBOutlet weak var FeedbacksubmitdateLabel: UILabel!
    @IBOutlet weak var feedbacksubjectLabel: UILabel!
    @IBOutlet weak var feedbackIdlabel: UILabel!
    @IBOutlet weak var Statuscontainerview: UIView!

    // MARK: - Header labels (Figma: "Activity" + bell "Following")
    private let activityTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Activity"
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = UIColor(red: 0.07, green: 0.09, blue: 0.15, alpha: 1) // #111827
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let followingImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "bell"))
        imageView.tintColor = UIColor(red: 0.23, green: 0.51, blue: 0.96, alpha: 1) // Blue
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let followingLabel: UILabel = {
        let label = UILabel()
        label.text = "Following"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor(red: 0.23, green: 0.51, blue: 0.96, alpha: 1) // Blue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Dynamic Timeline Storage
    private var timelineItemViews: [TimelineItemView] = []
    private var connectorViews: [UIView] = []

    // ✅ Dynamic height constraint for Statuscontainerview (replaces fixed XIB height)
    private var statusHeightConstraint: NSLayoutConstraint?

    // MARK: - Timeline Colors
    private let blueDotColor = UIColor(red: 0.23, green: 0.51, blue: 0.96, alpha: 1)
    private let orangeDotColor = UIColor(red: 0.96, green: 0.62, blue: 0.04, alpha: 1)
    private let greenDotColor = UIColor(red: 0.13, green: 0.70, blue: 0.38, alpha: 1)
    private let grayLineColor = UIColor(red: 0.90, green: 0.91, blue: 0.93, alpha: 1) // #E5E7EB

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()

        // ✅ Dynamic height for Feedbackmessagelabel & Feedbackmessagebackgroundview
        Feedbackmessagelabel.numberOfLines = 0
        Feedbackmessagelabel.lineBreakMode = .byWordWrapping
        Feedbackmessagelabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        Feedbackmessagelabel.setContentCompressionResistancePriority(.required, for: .vertical)

        setupStatusContainerView()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        clearTimeline()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: - Setup (Figma: white card, radius 16, border 1px, padding 13)
    // NOTE: Only header ("Activity" + "Following") is set up here.
    // Timeline items are built dynamically in rebuildTimeline(with:) based on API data.
    private func setupStatusContainerView() {
        Statuscontainerview.backgroundColor = .white
        Statuscontainerview.layer.cornerRadius = 16
        Statuscontainerview.layer.borderWidth = 1
        Statuscontainerview.layer.borderColor = grayLineColor.cgColor
        Statuscontainerview.clipsToBounds = true

        // ✅ REMOVE fixed height from XIB so timeline can grow freely
        removeFixedHeightConstraints(from: Statuscontainerview)

        // ✅ Add our own dynamic height constraint (updated after timeline rebuild)
        let heightConstraint = Statuscontainerview.heightAnchor.constraint(equalToConstant: 50)
        heightConstraint.priority = UILayoutPriority(999)
        heightConstraint.isActive = true
        statusHeightConstraint = heightConstraint

        Statuscontainerview.addSubview(activityTitleLabel)
        Statuscontainerview.addSubview(followingImageView)
        Statuscontainerview.addSubview(followingLabel)

        NSLayoutConstraint.activate([
            // Header row
            activityTitleLabel.topAnchor.constraint(equalTo: Statuscontainerview.topAnchor, constant: 13),
            activityTitleLabel.leadingAnchor.constraint(equalTo: Statuscontainerview.leadingAnchor, constant: 13),

            // "Following" on right: bell icon + label
            followingLabel.centerYAnchor.constraint(equalTo: activityTitleLabel.centerYAnchor),
            followingLabel.trailingAnchor.constraint(equalTo: Statuscontainerview.trailingAnchor, constant: -13),

            followingImageView.centerYAnchor.constraint(equalTo: followingLabel.centerYAnchor),
            followingImageView.trailingAnchor.constraint(equalTo: followingLabel.leadingAnchor, constant: -6),
            followingImageView.widthAnchor.constraint(equalToConstant: 16),
            followingImageView.heightAnchor.constraint(equalToConstant: 16)
        ])
    }

    // ✅ Strip any height constraints that came from the XIB / storyboard
    private func removeFixedHeightConstraints(from view: UIView) {
        // Height constraints attached directly on the view
        view.constraints
            .filter { $0.firstAttribute == .height || $0.secondAttribute == .height }
            .forEach { view.removeConstraint($0) }

        // Height constraints from the superview targeting this view
        if let superview = view.superview {
            superview.constraints
                .filter {
                    let isHeight = $0.firstAttribute == .height || $0.secondAttribute == .height
                    let involvesView = ($0.firstItem as? UIView) == view || ($0.secondItem as? UIView) == view
                    return isHeight && involvesView
                }
                .forEach { superview.removeConstraint($0) }
        }
    }

    // MARK: - Clear existing timeline views (used on reuse + before rebuild)
    private func clearTimeline() {
        timelineItemViews.forEach { $0.removeFromSuperview() }
        connectorViews.forEach { $0.removeFromSuperview() }
        timelineItemViews.removeAll()
        connectorViews.removeAll()
    }

    // MARK: - Timeline Entry Model
    private struct TimelineEntry {
        let title: String
        let subtitle: String
        let dotColor: UIColor
    }

    // MARK: - Build Timeline Dynamically from Entries
    private func rebuildTimeline(with entries: [TimelineEntry]) {

        clearTimeline()

        guard !entries.isEmpty else {
            statusHeightConstraint?.constant = 50
            return
        }

        var previousTopAnchorView: UIView = activityTitleLabel
        var previousItemView: TimelineItemView?

        for (index, entry) in entries.enumerated() {

            let itemView = TimelineItemView(
                title: entry.title,
                subtitle: entry.subtitle,
                dotColor: entry.dotColor
            )

            Statuscontainerview.addSubview(itemView)
            timelineItemViews.append(itemView)

            let topConstant: CGFloat = (index == 0) ? 14 : 9

            NSLayoutConstraint.activate([
                itemView.leadingAnchor.constraint(equalTo: Statuscontainerview.leadingAnchor, constant: 13),
                itemView.trailingAnchor.constraint(equalTo: Statuscontainerview.trailingAnchor, constant: -13),
                itemView.topAnchor.constraint(
                    equalTo: previousTopAnchorView.bottomAnchor,
                    constant: topConstant
                )
            ])

            // ❌ DO NOT pin last item to bottom of container anymore.
            // That fought the fixed XIB height and crushed/overlapped the labels.
            // Height is now driven by statusHeightConstraint (see updateStatusContainerHeight).

            // Connector line joining previous dot -> current dot
            if let prevItem = previousItemView {
                let connector = UIView()
                connector.backgroundColor = grayLineColor
                connector.layer.cornerRadius = 1
                connector.translatesAutoresizingMaskIntoConstraints = false

                Statuscontainerview.addSubview(connector)
                connectorViews.append(connector)

                NSLayoutConstraint.activate([
                    connector.centerXAnchor.constraint(equalTo: prevItem.dotCenterXAnchor),
                    connector.widthAnchor.constraint(equalToConstant: 2),
                    connector.topAnchor.constraint(equalTo: prevItem.dotBottomAnchor, constant: 4),
                    connector.bottomAnchor.constraint(equalTo: itemView.dotTopAnchor, constant: -4)
                ])
            }

            previousTopAnchorView = itemView
            previousItemView = itemView
        }

        // ✅ Resize Statuscontainerview so every title + subtitle is fully visible
        updateStatusContainerHeight()
    }

    // ✅ Compute exact height needed by header + all timeline items and apply it
    private func updateStatusContainerHeight() {
        // Force layout so intrinsic sizes are valid
        Statuscontainerview.layoutIfNeeded()

        let contentWidth = max(Statuscontainerview.bounds.width - 26, UIScreen.main.bounds.width - 64)

        // Top padding + header label height
        var totalHeight: CGFloat = 13
        totalHeight += activityTitleLabel.intrinsicContentSize.height
        totalHeight += 14 // gap under header before first item

        for (index, itemView) in timelineItemViews.enumerated() {
            let size = itemView.systemLayoutSizeFitting(
                CGSize(width: contentWidth, height: UIView.layoutFittingCompressedSize.height),
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel
            )
            totalHeight += ceil(size.height)
            if index < timelineItemViews.count - 1 {
                totalHeight += 9 // spacing between items
            }
        }

        totalHeight += 13 // bottom padding

        statusHeightConstraint?.constant = totalHeight
        Statuscontainerview.layoutIfNeeded()
    }

    // MARK: - Public update (manual / fallback)
    func configureActivity(
        firstTitle: String, firstSubtitle: String,
        secondTitle: String, secondSubtitle: String
    ) {
        rebuildTimeline(with: [
            TimelineEntry(title: firstTitle, subtitle: firstSubtitle, dotColor: blueDotColor),
            TimelineEntry(title: secondTitle, subtitle: secondSubtitle, dotColor: blueDotColor)
        ])
    }

    // MARK: - ✅ Configure with API Feedback Data
    func configure(with feedback: Feedback) {

        print("FeedbackinreviewTBLVWCell configure() called with subject:", feedback.subject)

        // Feedback ID
        feedbackIdlabel.text = "#\(feedback.id)"

        // Category
        Catogerylabel.text = feedback.category.name

        // Subject
        feedbacksubjectLabel.text = feedback.subject

        // Feedback message
        Feedbackmessagelabel.text = feedback.message

        // Submit date (used only for combined label below — FeedbacksubmitdateLabel is NOT set dynamically)
        let submitDate = formatDate(feedback.createdAt)

        // Combined: Student name • Category • Submit date
        submitparentandgradeanddatelabel.text =
            "\(feedback.student.name) • \(feedback.category.name) • \(submitDate)"

        // ── Latest response message + date (if any) ──
        if let latestResponse = feedback.responses.sorted(by: { lhs, rhs in
            (parseISODate(lhs.createdAt) ?? Date.distantPast) <
            (parseISODate(rhs.createdAt) ?? Date.distantPast)
        }).last {
            ResponsemessageLabel.text = latestResponse.message
            Responsedatelabel.text = formatDateTime(latestResponse.createdAt)
        } else {
            ResponsemessageLabel.text = "No response yet"
            Responsedatelabel.text = ""
        }

        // ✅ Configure Father Name labels from UserManager
        configureFatherNameLabels()

        // ── Build full Activity timeline dynamically from API data ──
        configureActivityTimeline(with: feedback)
    }

    // MARK: - ✅ Configure Father Name + First Two Letters Avatar (from UserManager)
    private func configureFatherNameLabels() {

        let fatherName = UserManager.shared.resolvedFatherName
        print("👨 Father Name from UserManager:", fatherName)

        // Full father name label
        FathernameLabel.text = fatherName.isEmpty ? "--" : fatherName

        // First two letters label (used as avatar initials)
        let initials = extractFirstTwoLetters(from: fatherName)
        FathernamefirsttwolettersLabel.text = initials
        print("🔤 Father Initials:", initials)
    }

    // MARK: - ✅ Extract First Two Letters Helper
    private func extractFirstTwoLetters(from name: String) -> String {

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return "--" }

        // Split by spaces to try getting First + Last initials, else fallback to first 2 characters
        let components = trimmedName
            .components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }

        if components.count >= 2,
           let first = components.first?.first,
           let second = components.dropFirst().first?.first {
            return "\(first)\(second)".uppercased()
        }

        // Single-word name → take first two letters
        let firstTwo = trimmedName.prefix(2)
        return String(firstTwo).uppercased()
    }

    // MARK: - ✅ Build Full Activity Timeline (submission + each response + in-review status)
    private func configureActivityTimeline(with feedback: Feedback) {

        var entries: [TimelineEntry] = []

        // 1️⃣ Always first: Feedback submitted (real createdAt date)
        entries.append(
            TimelineEntry(
                title: "Feedback submitted",
                subtitle: formatDateTime(feedback.createdAt),
                dotColor: blueDotColor
            )
        )

        // 2️⃣ One entry per API response (school replies), sorted oldest → newest
        let sortedResponses = feedback.responses.sorted { lhs, rhs in
            (parseISODate(lhs.createdAt) ?? Date.distantPast) <
            (parseISODate(rhs.createdAt) ?? Date.distantPast)
        }

        for response in sortedResponses {
            let responderName = response.respondedBy.name ?? "Admin"
            entries.append(
                TimelineEntry(
                    title: "\(responderName) replied · Review started",
                    subtitle: formatDateTime(response.createdAt),
                    dotColor: blueDotColor
                )
            )
        }

        // 3️⃣ Final status entry (real updatedAt date)
        entries.append(finalStatusEntry(status: feedback.status, updatedAt: feedback.updatedAt))

        // Build timeline UI
        rebuildTimeline(with: entries)
    }

    // MARK: - Final Status Timeline Entry (status aware, real date)
    private func finalStatusEntry(status: String, updatedAt: String) -> TimelineEntry {

        let statusValue = status.uppercased()

        switch statusValue {

        case "SUBMITTED", "PENDING":
            return TimelineEntry(
                title: "Waiting for school review",
                subtitle: "Expected within 2 school days",
                dotColor: orangeDotColor
            )

        case "IN_REVIEW", "IN REVIEW":
            return TimelineEntry(
                title: "Feedback is under review",
                subtitle: formatDateTime(updatedAt),
                dotColor: blueDotColor
            )

        case "RESOLVED":
            return TimelineEntry(
                title: "Marked as resolved",
                subtitle: formatDateTime(updatedAt),
                dotColor: greenDotColor
            )

        default:
            return TimelineEntry(
                title: status.capitalized,
                subtitle: formatDateTime(updatedAt),
                dotColor: orangeDotColor
            )
        }
    }

    // MARK: - Date Formatting Helpers
    private func formatDate(_ dateString: String) -> String {

        guard let date = parseISODate(dateString) else { return dateString }

        let outputFormatter = DateFormatter()
        outputFormatter.locale = Locale(identifier: "en_US_POSIX")
        outputFormatter.dateFormat = "dd MMM yyyy"

        return outputFormatter.string(from: date)
    }

    private func formatDateTime(_ dateString: String) -> String {

        guard let date = parseISODate(dateString) else { return dateString }

        let outputFormatter = DateFormatter()
        outputFormatter.locale = Locale(identifier: "en_US_POSIX")
        outputFormatter.dateFormat = "dd MMM yyyy · h:mm a"

        return outputFormatter.string(from: date)
    }

    private func parseISODate(_ dateString: String) -> Date? {

        // Try with fractional seconds first
        let formatterWithFraction = ISO8601DateFormatter()
        formatterWithFraction.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        if let date = formatterWithFraction.date(from: dateString) {
            return date
        }

        // Fallback: without fractional seconds
        let formatterPlain = ISO8601DateFormatter()
        formatterPlain.formatOptions = [.withInternetDateTime]

        return formatterPlain.date(from: dateString)
    }
}

// MARK: - TimelineItemView (dot + title + subtitle)
private final class TimelineItemView: UIView {

    private let dotView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        label.textColor = UIColor(red: 0.07, green: 0.09, blue: 0.15, alpha: 1) // #111827
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        // ✅ Never allow title to be vertically crushed / overlapped
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor(red: 0.42, green: 0.45, blue: 0.50, alpha: 1) // #6B7280
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        // ✅ Never allow subtitle to be vertically crushed / overlapped
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()

    // Exposed anchors so the connector line can join dot-to-dot
    var dotCenterXAnchor: NSLayoutXAxisAnchor { dotView.centerXAnchor }
    var dotBottomAnchor: NSLayoutYAxisAnchor { dotView.bottomAnchor }
    var dotTopAnchor: NSLayoutYAxisAnchor { dotView.topAnchor }

    init(title: String, subtitle: String, dotColor: UIColor) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        dotView.backgroundColor = dotColor
        titleLabel.text = title
        subtitleLabel.text = subtitle

        addSubview(dotView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            // Dot aligned with title line
            dotView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dotView.widthAnchor.constraint(equalToConstant: 10),
            dotView.heightAnchor.constraint(equalToConstant: 10),
            dotView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),

            // Labels
            titleLabel.leadingAnchor.constraint(equalTo: dotView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
}
