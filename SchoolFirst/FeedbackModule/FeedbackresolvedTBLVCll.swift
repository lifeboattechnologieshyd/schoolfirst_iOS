//
//  FeedbackresolvedTBLVCll.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 13/10/26.
//

import UIKit

class FeedbackresolvedTBLVCll: UITableViewCell {

    @IBOutlet weak var FathernamefirsttwolettersLabel: UILabel!
    @IBOutlet weak var FathernameLabel: UILabel!
    @IBOutlet weak var AcadamicLabel: UILabel!
    @IBOutlet weak var feedbackmessageLabel: UILabel!
    @IBOutlet weak var Resposnemessagelabel: UILabel!
    @IBOutlet weak var Responsedatenadtimelabel: UILabel!
    @IBOutlet weak var parentandsubmitdategradeLabel: UILabel!
    @IBOutlet weak var SubmittimeLabe: UILabel!
    @IBOutlet weak var feedbacksubjectlabel: UILabel!
    @IBOutlet weak var feedbackIdLabel: UILabel!
    @IBOutlet weak var Statusviewcantainer: UIView!

    // MARK: - Header label (Figma: "Activity")
    private let activityTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Activity"
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = UIColor(red: 0.07, green: 0.09, blue: 0.15, alpha: 1) // #111827
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Dynamic Timeline Storage
    private var timelineItemViews: [TimelineItemView] = []
    private var connectorViews: [UIView] = []

    // MARK: - Timeline Colors
    private let blueDotColor = UIColor(red: 0.23, green: 0.51, blue: 0.96, alpha: 1)
    private let greenDotColor = UIColor(red: 0.13, green: 0.70, blue: 0.38, alpha: 1)
    private let orangeDotColor = UIColor(red: 0.96, green: 0.62, blue: 0.04, alpha: 1)
    private let grayLineColor = UIColor(red: 0.90, green: 0.91, blue: 0.93, alpha: 1) // #E5E7EB

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupStatusViewContainer()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        clearTimeline()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: - Setup (Figma: white card, radius 16, border 1px, padding 11)
    private func setupStatusViewContainer() {
        Statusviewcantainer.backgroundColor = .white
        Statusviewcantainer.layer.cornerRadius = 16
        Statusviewcantainer.layer.borderWidth = 1
        Statusviewcantainer.layer.borderColor = grayLineColor.cgColor
        Statusviewcantainer.clipsToBounds = true

        Statusviewcantainer.addSubview(activityTitleLabel)

        NSLayoutConstraint.activate([
            activityTitleLabel.topAnchor.constraint(equalTo: Statusviewcantainer.topAnchor, constant: 11),
            activityTitleLabel.leadingAnchor.constraint(equalTo: Statusviewcantainer.leadingAnchor, constant: 11)
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

            Statusviewcantainer.addSubview(itemView)
            timelineItemViews.append(itemView)

            NSLayoutConstraint.activate([
                itemView.leadingAnchor.constraint(equalTo: Statusviewcantainer.leadingAnchor, constant: 11),
                itemView.trailingAnchor.constraint(equalTo: Statusviewcantainer.trailingAnchor, constant: -11)
            ])

            if index == 0 {
                itemView.topAnchor.constraint(
                    equalTo: previousTopAnchorView.bottomAnchor,
                    constant: 12
                ).isActive = true
            } else {
                itemView.topAnchor.constraint(
                    equalTo: previousTopAnchorView.bottomAnchor,
                    constant: 6
                ).isActive = true
            }

            // Last item pins to bottom of container
            if index == entries.count - 1 {
                itemView.bottomAnchor.constraint(
                    equalTo: Statusviewcantainer.bottomAnchor,
                    constant: -11
                ).isActive = true
            }

            // Connector line joining previous dot -> current dot
            if let prevItem = previousItemView {
                let connector = UIView()
                connector.backgroundColor = grayLineColor
                connector.layer.cornerRadius = 1
                connector.translatesAutoresizingMaskIntoConstraints = false

                Statusviewcantainer.addSubview(connector)
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
        secondTitle: String, secondSubtitle: String,
        thirdTitle: String, thirdSubtitle: String
    ) {
        rebuildTimeline(with: [
            TimelineEntry(title: firstTitle, subtitle: firstSubtitle, dotColor: blueDotColor),
            TimelineEntry(title: secondTitle, subtitle: secondSubtitle, dotColor: blueDotColor),
            TimelineEntry(title: thirdTitle, subtitle: thirdSubtitle, dotColor: greenDotColor)
        ])
    }

    // MARK: - ✅ Configure with API Feedback Data
    func configure(with feedback: Feedback) {
        print("🧩 FeedbackresolvedTBLVCll configure() called with subject:", feedback.subject)

        // Feedback ID
        feedbackIdLabel.text = "#\(feedback.id)"

        // Category (Academic / Transport / etc.)
        AcadamicLabel.text = feedback.category.name

        // Subject
        feedbacksubjectlabel.text = feedback.subject

        // Feedback message
        feedbackmessageLabel.text = feedback.message

        // Dates & Times
        let submitDate = formatDate(feedback.createdAt)
        let resolvedDate = formatDate(feedback.updatedAt)
        
        // Resolver Name (from latest response or fallback to SchoolFirst Admin)
        let resolverName = feedback.responses.last?.respondedBy.name ?? "SchoolFirst Admin"

        // ── Resolved/Submit Time Label Configuration ──
        if feedback.status.uppercased() == "RESOLVED" {
            // Output: "Resolved by SchoolFirst Admin · 17 Aug 2026"
            SubmittimeLabe.text = "Resolved by \(resolverName) · \(resolvedDate)"
        } else {
            let submitTime = formatTime(feedback.createdAt)
            SubmittimeLabe.text = "Submitted at \(submitTime) · \(submitDate)"
        }

        // Combined: Student name • Grade/Category • Submit date
        parentandsubmitdategradeLabel.text = "\(feedback.student.name) • \(feedback.category.name) • \(submitDate)"

        // ── Latest response message + date/time (if any) ──
        if let latestResponse = feedback.responses.sorted(by: { lhs, rhs in
            (parseISODate(lhs.createdAt) ?? Date.distantPast) <
            (parseISODate(rhs.createdAt) ?? Date.distantPast)
        }).last {
            Resposnemessagelabel.text = latestResponse.message
            Responsedatenadtimelabel.text = formatDateTime(latestResponse.createdAt)
        } else {
            Resposnemessagelabel.text = "No response yet"
            Responsedatenadtimelabel.text = ""
        }

        // ✅ Configure Father Name labels from UserManager
        configureFatherNameLabels()

        // ── Build full Activity timeline dynamically from API data ──
        configureActivityTimeline(with: feedback)
    }

    // MARK: - ✅ Configure Father Name + First Two Letters Avatar
    private func configureFatherNameLabels() {

        let fatherName = UserManager.shared.resolvedFatherName
        print("👨 Father:", fatherName)

        // Full father name label
        FathernameLabel.text = fatherName.isEmpty ? "--" : fatherName

        // First two letters label (used as avatar initials)
        let initials = extractFirstTwoLetters(from: fatherName)
        FathernamefirsttwolettersLabel.text = initials
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

    // MARK: - ✅ Build Full Activity Timeline (submission + each response + resolved status)
    private func configureActivityTimeline(with feedback: Feedback) {
        var entries: [TimelineEntry] = []

        // 1️⃣ Feedback submitted (real createdAt date)
        entries.append(
            TimelineEntry(
                title: "Feedback submitted",
                subtitle: formatDateTime(feedback.createdAt),
                dotColor: blueDotColor
            )
        )

        // 2️⃣ Responses sorted oldest → newest
        let sortedResponses = feedback.responses.sorted { lhs, rhs in
            (parseISODate(lhs.createdAt) ?? Date.distantPast) <
            (parseISODate(rhs.createdAt) ?? Date.distantPast)
        }

        for response in sortedResponses {
            let responderName = response.respondedBy.name ?? "Admin"
            entries.append(
                TimelineEntry(
                    title: "\(responderName) replied",
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
                dotColor: orangeDotColor
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

    private func formatTime(_ dateString: String) -> String {
        guard let date = parseISODate(dateString) else { return dateString }
        let outputFormatter = DateFormatter()
        outputFormatter.locale = Locale(identifier: "en_US_POSIX")
        outputFormatter.dateFormat = "h:mm a"
        return outputFormatter.string(from: date)
    }

    private func formatDateTime(_ dateString: String) -> String {
        guard let date = parseISODate(dateString) else { return dateString }
        let outputFormatter = DateFormatter()
        outputFormatter.locale = Locale(identifier: "en_US_POSIX")
        outputFormatter.dateFormat = "dd MMM · h:mm a"
        return outputFormatter.string(from: date)
    }

    private func parseISODate(_ dateString: String) -> Date? {
        let formatterWithFraction = ISO8601DateFormatter()
        formatterWithFraction.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        if let date = formatterWithFraction.date(from: dateString) {
            return date
        }

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

    func update(title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
}
