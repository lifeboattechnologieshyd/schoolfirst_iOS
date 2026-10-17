//
//  FeedbacksummuryTBLVWCell.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 12/10/26.
//

import UIKit

class FeedbacksummuryTBLVWCell: UITableViewCell {

    @IBOutlet weak var view2: UILabel!
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var Fathernamefirsttwoletterslabel: UILabel!
    @IBOutlet weak var fathernameLabel: UILabel!
    @IBOutlet weak var Statuscontainerview: UIView!

    @IBOutlet weak var FeedbacksumbitdategradeandparentnameLabel: UILabel!
    @IBOutlet weak var CatogeryLabel: UILabel!
    @IBOutlet weak var FeedbackSubjectLabel: UILabel!
    @IBOutlet weak var FeedbackmessageLabel: UILabel!
    @IBOutlet weak var FeedbackIdLabel: UILabel!
    @IBOutlet weak var SubmitdateLabel: UILabel!

    // MARK: - Header labels (Figma: "Activity" + "Latest first")
    private let activityTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Activity"
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = UIColor(red: 0.07, green: 0.09, blue: 0.15, alpha: 1) // #111827
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let latestFirstLabel: UILabel = {
        let label = UILabel()
        label.text = "Latest first"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor(red: 0.61, green: 0.64, blue: 0.69, alpha: 1) // #9CA3AF
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Dynamic Timeline Storage
    private var timelineItemViews: [TimelineItemView] = []
    private var connectorViews: [UIView] = []
    private var timelineBottomConstraint: NSLayoutConstraint?

    // Keep strong refs so we can replace height constraints on reuse
    private var view1HeightConstraint: NSLayoutConstraint?
    private var view2HeightConstraint: NSLayoutConstraint?

    // MARK: - Timeline Colors
    private let blueDotColor = UIColor(red: 0.23, green: 0.51, blue: 0.96, alpha: 1)
    private let orangeDotColor = UIColor(red: 0.96, green: 0.62, blue: 0.04, alpha: 1)
    private let greenDotColor = UIColor(red: 0.15, green: 0.65, blue: 0.30, alpha: 1)
    private let grayLineColor = UIColor(red: 0.90, green: 0.91, blue: 0.93, alpha: 1) // #E5E7EB

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        setupDynamicLabelsAndViews()
        setupStatusContainerView()
        verifyOutlets()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        clearTimeline()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: - ✅ Make FeedbackSubjectLabel, FeedbackmessageLabel, view1, view2 dynamic
    private func setupDynamicLabelsAndViews() {

        // ── Subject label ──
        FeedbackSubjectLabel.numberOfLines = 0
        FeedbackSubjectLabel.lineBreakMode = .byWordWrapping
        FeedbackSubjectLabel.setContentHuggingPriority(.required, for: .vertical)
        FeedbackSubjectLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        // ── Message label ──
        FeedbackmessageLabel.numberOfLines = 0
        FeedbackmessageLabel.lineBreakMode = .byWordWrapping
        FeedbackmessageLabel.setContentHuggingPriority(.required, for: .vertical)
        FeedbackmessageLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        // ── view2 is UILabel — allow multi-line ──
        view2?.numberOfLines = 0
        view2?.lineBreakMode = .byWordWrapping
        view2?.setContentHuggingPriority(.required, for: .vertical)
        view2?.setContentCompressionResistancePriority(.required, for: .vertical)

        // ── CRITICAL: remove fixed height constraints from XIB ──
        // Without this, view1 / view2 stay locked and clip the labels.
        stripFixedHeight(from: FeedbackSubjectLabel)
        stripFixedHeight(from: FeedbackmessageLabel)
        stripFixedHeight(from: view1)
        stripFixedHeight(from: view2)
        stripFixedHeight(from: Statuscontainerview)
    }

    /// Deactivates any `height == constant` constraint on the view
    /// (own constraints + superview constraints that target this view).
    private func stripFixedHeight(from view: UIView?) {
        guard let view = view else { return }

        // Constraints owned by the view itself
        view.constraints.forEach { c in
            if c.firstAttribute == .height && c.relation == .equal && c.secondItem == nil {
                c.isActive = false
            }
        }

        // Constraints from superview that set this view's height
        view.superview?.constraints.forEach { c in
            let isThisView =
                (c.firstItem as? UIView) == view || (c.secondItem as? UIView) == view
            if isThisView && c.firstAttribute == .height && c.relation == .equal {
                c.isActive = false
            }
        }
    }

    // MARK: - Debug
    private func verifyOutlets() {
        if Statuscontainerview == nil { print("❌ Statuscontainerview outlet is NOT connected") }
        if FeedbacksumbitdategradeandparentnameLabel == nil { print("❌ FeedbacksumbitdategradeandparentnameLabel outlet is NOT connected") }
        if CatogeryLabel == nil { print("❌ CatogeryLabel outlet is NOT connected") }
        if FeedbackSubjectLabel == nil { print("❌ FeedbackSubjectLabel outlet is NOT connected") }
        if FeedbackmessageLabel == nil { print("❌ FeedbackmessageLabel outlet is NOT connected") }
        if FeedbackIdLabel == nil { print("❌ FeedbackIdLabel outlet is NOT connected") }
        if SubmitdateLabel == nil { print("❌ SubmitdateLabel outlet is NOT connected") }
        if view1 == nil { print("❌ view1 outlet is NOT connected") }
        if view2 == nil { print("❌ view2 outlet is NOT connected") }
    }

    // MARK: - Setup Activity card chrome
    private func setupStatusContainerView() {
        Statuscontainerview.backgroundColor = .white
        Statuscontainerview.layer.cornerRadius = 16
        Statuscontainerview.layer.borderWidth = 1
        Statuscontainerview.layer.borderColor = grayLineColor.cgColor
        Statuscontainerview.clipsToBounds = true

        Statuscontainerview.addSubview(activityTitleLabel)
        Statuscontainerview.addSubview(latestFirstLabel)

        NSLayoutConstraint.activate([
            activityTitleLabel.topAnchor.constraint(equalTo: Statuscontainerview.topAnchor, constant: 14),
            activityTitleLabel.leadingAnchor.constraint(equalTo: Statuscontainerview.leadingAnchor, constant: 14),

            latestFirstLabel.centerYAnchor.constraint(equalTo: activityTitleLabel.centerYAnchor),
            latestFirstLabel.trailingAnchor.constraint(equalTo: Statuscontainerview.trailingAnchor, constant: -14)
        ])
    }

    // MARK: - Clear timeline
    private func clearTimeline() {
        timelineItemViews.forEach { $0.removeFromSuperview() }
        connectorViews.forEach { $0.removeFromSuperview() }
        timelineItemViews.removeAll()
        connectorViews.removeAll()

        timelineBottomConstraint?.isActive = false
        timelineBottomConstraint = nil
    }

    // MARK: - Timeline Entry Model
    private struct TimelineEntry {
        let title: String
        let subtitle: String
        let dotColor: UIColor
    }

    // MARK: - Build Timeline + pin bottom so Statuscontainerview grows
    private func rebuildTimeline(with entries: [TimelineEntry]) {

        clearTimeline()

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

            NSLayoutConstraint.activate([
                itemView.leadingAnchor.constraint(equalTo: Statuscontainerview.leadingAnchor, constant: 14),
                itemView.trailingAnchor.constraint(equalTo: Statuscontainerview.trailingAnchor, constant: -14)
            ])

            let topGap: CGFloat = (index == 0) ? 16 : 11
            itemView.topAnchor.constraint(
                equalTo: previousTopAnchorView.bottomAnchor,
                constant: topGap
            ).isActive = true

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

        // Pin last item → bottom of Activity card (card height = content)
        if let lastItem = previousItemView {
            let bottom = lastItem.bottomAnchor.constraint(
                equalTo: Statuscontainerview.bottomAnchor,
                constant: -14
            )
            bottom.isActive = true
            timelineBottomConstraint = bottom
        } else {
            let bottom = activityTitleLabel.bottomAnchor.constraint(
                equalTo: Statuscontainerview.bottomAnchor,
                constant: -14
            )
            bottom.isActive = true
            timelineBottomConstraint = bottom
        }
    }

    // MARK: - Public fallback
    func configureActivity(
        firstTitle: String, firstSubtitle: String,
        secondTitle: String, secondSubtitle: String
    ) {
        rebuildTimeline(with: [
            TimelineEntry(title: firstTitle, subtitle: firstSubtitle, dotColor: blueDotColor),
            TimelineEntry(title: secondTitle, subtitle: secondSubtitle, dotColor: orangeDotColor)
        ])
    }

    // MARK: - ✅ Configure with API Feedback Data
    func configure(with feedback: Feedback) {

        print("🧩 Cell configure() called with subject:", feedback.subject)

        let fatherName = UserManager.shared.resolvedFatherName
        let displayName = fatherName.isEmpty ? "Parent" : fatherName
        fathernameLabel.text = displayName
        Fathernamefirsttwoletterslabel.text = fatherInitials(from: displayName)

        FeedbackIdLabel.text = "#\(feedback.id)"
        CatogeryLabel.text = feedback.category.name

        // Subject + Message (multi-line labels)
        FeedbackSubjectLabel.text = feedback.subject
        FeedbackmessageLabel.text = feedback.message

        let shortDate = formatDate(feedback.createdAt)
        SubmitdateLabel.text = "Submitted \(shortDate) · Awaiting initial review"
        FeedbacksumbitdategradeandparentnameLabel.text =
            "\(feedback.student.name) • \(feedback.category.name) • \(shortDate)"

        // Build timeline
        configureActivityTimeline(with: feedback)

        // ✅ After text is set, force view1 / view2 to expand to fit labels
        expandView1AndView2()
    }

    // MARK: - ✅ Dynamically size view1 & view2 to fit their labels
    private func expandView1AndView2() {

        let screenW = UIScreen.main.bounds.width
        // Inner content width ≈ screen - outer margin - card padding
        let contentW = max(screenW - 72, 280)

        // --- Subject height (lives in dark header; often related to view2 or sibling) ---
        let subjectFont = FeedbackSubjectLabel.font ?? UIFont.systemFont(ofSize: 22, weight: .bold)
        let subjectH = ceil((FeedbackSubjectLabel.text ?? "").boundingRect(
            with: CGSize(width: contentW, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: subjectFont],
            context: nil
        ).height)

        // --- Message height (lives inside view1) ---
        let messageFont = FeedbackmessageLabel.font ?? UIFont.systemFont(ofSize: 15, weight: .regular)
        let messageH = ceil((FeedbackmessageLabel.text ?? "").boundingRect(
            with: CGSize(width: contentW, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: messageFont],
            context: nil
        ).height)

        // view1 = white card that holds parent row + message
        // base chrome (avatar row + padding) ≈ 70, plus message + bottom pad
        let view1Total = max(70 + messageH + 24, 120)
        applyHeight(view1Total, to: view1, storingIn: &view1HeightConstraint)

        // view2 is UILabel — size it to its own text if it has any;
        // otherwise give it subject-related space if used as subject container label
        if let v2 = view2 {
            let v2Text = v2.text ?? FeedbackSubjectLabel.text ?? ""
            let v2Font = v2.font ?? subjectFont
            let v2H = ceil(v2Text.boundingRect(
                with: CGSize(width: contentW, height: .greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: [.font: v2Font],
                context: nil
            ).height)
            // If view2 is just a small label, don't force huge height;
            // if it holds subject-like text, use measured height.
            let finalV2 = max(v2H + 8, 20)
            applyHeight(finalV2, to: v2, storingIn: &view2HeightConstraint)
        }

        // Also ensure subject label itself can show full text
        // (in case a leftover height constraint still fights it)
        stripFixedHeight(from: FeedbackSubjectLabel)
        stripFixedHeight(from: FeedbackmessageLabel)

        setNeedsLayout()
        layoutIfNeeded()
    }

    private func applyHeight(_ height: CGFloat, to view: UIView?, storingIn storage: inout NSLayoutConstraint?) {
        guard let view = view else { return }

        // Remove previous dynamic height we added
        storage?.isActive = false
        storage = nil

        // Strip any remaining fixed heights from XIB
        stripFixedHeight(from: view)

        let c = view.heightAnchor.constraint(equalToConstant: height)
        c.priority = UILayoutPriority(999) // high but not required — avoids unsatisfiable conflicts
        c.isActive = true
        storage = c
    }

    // MARK: - Father initials
    private func fatherInitials(from name: String) -> String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "P" }

        let parts = trimmed.split(separator: " ")
        if parts.count >= 2 {
            let first = String(parts[0].prefix(1))
            let last  = String(parts[1].prefix(1))
            return (first + last).uppercased()
        } else {
            return String(trimmed.prefix(2)).uppercased()
        }
    }

    // MARK: - Activity timeline from API
    private func configureActivityTimeline(with feedback: Feedback) {

        var entries: [TimelineEntry] = []

        entries.append(
            TimelineEntry(
                title: "Feedback submitted",
                subtitle: formatDateTime(feedback.createdAt),
                dotColor: blueDotColor
            )
        )

        let sortedResponses = feedback.responses.sorted { lhs, rhs in
            (parseISODate(lhs.createdAt) ?? Date.distantPast) <
            (parseISODate(rhs.createdAt) ?? Date.distantPast)
        }

        for response in sortedResponses {
            let responderName = response.respondedBy.name ?? "School"
            entries.append(
                TimelineEntry(
                    title: "\(responderName) replied: \(response.message)",
                    subtitle: formatDateTime(response.createdAt),
                    dotColor: greenDotColor
                )
            )
        }

        entries.append(finalStatusEntry(status: feedback.status, updatedAt: feedback.updatedAt))
        rebuildTimeline(with: entries)
    }

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
                dotColor: orangeDotColor
            )
        case "RESOLVED":
            return TimelineEntry(
                title: "Feedback resolved",
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

    // MARK: - Date helpers
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
        let formatterWithFraction = ISO8601DateFormatter()
        formatterWithFraction.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatterWithFraction.date(from: dateString) { return date }

        let formatterPlain = ISO8601DateFormatter()
        formatterPlain.formatOptions = [.withInternetDateTime]
        return formatterPlain.date(from: dateString)
    }
}

// MARK: - TimelineItemView
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
        label.textColor = UIColor(red: 0.07, green: 0.09, blue: 0.15, alpha: 1)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor(red: 0.42, green: 0.45, blue: 0.50, alpha: 1)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

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
            dotView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dotView.widthAnchor.constraint(equalToConstant: 10),
            dotView.heightAnchor.constraint(equalToConstant: 10),
            dotView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),

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
}
