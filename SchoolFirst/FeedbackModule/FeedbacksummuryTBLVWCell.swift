//
//  FeedbacksummuryTBLVWCell.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 12/10/26.
//

import UIKit

class FeedbacksummuryTBLVWCell: UITableViewCell {

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

    // MARK: - Timeline Colors
    private let blueDotColor = UIColor(red: 0.23, green: 0.51, blue: 0.96, alpha: 1)
    private let orangeDotColor = UIColor(red: 0.96, green: 0.62, blue: 0.04, alpha: 1)
    private let greenDotColor = UIColor(red: 0.15, green: 0.65, blue: 0.30, alpha: 1)
    private let grayLineColor = UIColor(red: 0.90, green: 0.91, blue: 0.93, alpha: 1) // #E5E7EB

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
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

    // MARK: - Debug — confirm all IBOutlets are connected in Storyboard/XIB
    private func verifyOutlets() {
        if Statuscontainerview == nil { print("❌ Statuscontainerview outlet is NOT connected") }
        if FeedbacksumbitdategradeandparentnameLabel == nil { print("❌ FeedbacksumbitdategradeandparentnameLabel outlet is NOT connected") }
        if CatogeryLabel == nil { print("❌ CatogeryLabel outlet is NOT connected") }
        if FeedbackSubjectLabel == nil { print("❌ FeedbackSubjectLabel outlet is NOT connected") }
        if FeedbackmessageLabel == nil { print("❌ FeedbackmessageLabel outlet is NOT connected") }
        if FeedbackIdLabel == nil { print("❌ FeedbackIdLabel outlet is NOT connected") }
        if SubmitdateLabel == nil { print("❌ SubmitdateLabel outlet is NOT connected") }
    }

    // MARK: - Setup (Figma: white card, radius 16, border 1px, padding 14)
    // NOTE: Only header ("Activity" + "Latest first") is set up here.
    // Timeline items are now built dynamically in rebuildTimeline(with:) based on API data.
    private func setupStatusContainerView() {
        Statuscontainerview.backgroundColor = .white
        Statuscontainerview.layer.cornerRadius = 16
        Statuscontainerview.layer.borderWidth = 1
        Statuscontainerview.layer.borderColor = grayLineColor.cgColor
        Statuscontainerview.clipsToBounds = true

        Statuscontainerview.addSubview(activityTitleLabel)
        Statuscontainerview.addSubview(latestFirstLabel)

        NSLayoutConstraint.activate([
            // Header row
            activityTitleLabel.topAnchor.constraint(equalTo: Statuscontainerview.topAnchor, constant: 14),
            activityTitleLabel.leadingAnchor.constraint(equalTo: Statuscontainerview.leadingAnchor, constant: 14),

            latestFirstLabel.centerYAnchor.constraint(equalTo: activityTitleLabel.centerYAnchor),
            latestFirstLabel.trailingAnchor.constraint(equalTo: Statuscontainerview.trailingAnchor, constant: -14)
        ])
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

            if index == 0 {
                itemView.topAnchor.constraint(
                    equalTo: previousTopAnchorView.bottomAnchor,
                    constant: 16
                ).isActive = true
            } else {
                itemView.topAnchor.constraint(
                    equalTo: previousTopAnchorView.bottomAnchor,
                    constant: 11
                ).isActive = true
            }

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
    }

    // MARK: - Public update (manual / fallback)
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

        // ── ✅ Father Name from DBManager ────────────────────────────────
        let fatherName = UserManager.shared.resolvedFatherName
        let displayName = fatherName.isEmpty ? "Parent" : fatherName
        fathernameLabel.text = displayName
        Fathernamefirsttwoletterslabel.text = fatherInitials(from: displayName)

        // Feedback ID
        FeedbackIdLabel.text = "#\(feedback.id)"

        // Category
        CatogeryLabel.text = feedback.category.name

        // Subject
        FeedbackSubjectLabel.text = feedback.subject

        // Message
        FeedbackmessageLabel.text = feedback.message

        // Submitted date (short)
        let shortDate = formatDate(feedback.createdAt)
        SubmitdateLabel.text = "Submitted \(shortDate) · Awaiting initial review"
        // Combined: Student name • Category • Date
        FeedbacksumbitdategradeandparentnameLabel.text =
            "\(feedback.student.name) • \(feedback.category.name) • \(shortDate)"

        // ── Build full Activity timeline dynamically from API data ──
        configureActivityTimeline(with: feedback)
    }

    // MARK: - ✅ Father Name Initials Helper
    /// "Ravi Kumar" → "RK"  |  "Ravi" → "RA"  |  "" → "P"
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

    // MARK: - ✅ Build Full Activity Timeline (submission + each response + current status)
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
            let responderName = response.respondedBy.name ?? "School"
            entries.append(
                TimelineEntry(
                    title: "\(responderName) replied: \(response.message)",
                    subtitle: formatDateTime(response.createdAt),
                    dotColor: greenDotColor
                )
            )
        }

        // 3️⃣ Final status-dependent entry (uses real updatedAt date)
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
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor(red: 0.42, green: 0.45, blue: 0.50, alpha: 1) // #6B7280
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
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
