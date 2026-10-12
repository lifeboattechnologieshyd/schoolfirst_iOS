//
//  FeedbackinreviewTBLVWCell.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 12/10/26.
//

import UIKit

class FeedbackinreviewTBLVWCell: UITableViewCell {

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

    // MARK: - Timeline items (both dots blue per Figma in-review screen)
    private lazy var firstTimelineItem: TimelineItemView = {
        let item = TimelineItemView(
            title: "Feedback submitted",
            subtitle: "16 Aug 2026 · 4:18 PM",
            dotColor: UIColor(red: 0.23, green: 0.51, blue: 0.96, alpha: 1) // Blue
        )
        return item
    }()

    private lazy var secondTimelineItem: TimelineItemView = {
        let item = TimelineItemView(
            title: "Admin reply sent · Review started",
            subtitle: "17 Aug 2026 · 10:42 AM",
            dotColor: UIColor(red: 0.23, green: 0.51, blue: 0.96, alpha: 1) // Blue
        )
        return item
    }()

    // Connecting vertical line between the two dots
    private let connectorLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.90, green: 0.91, blue: 0.93, alpha: 1) // #E5E7EB
        view.layer.cornerRadius = 1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupStatusContainerView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: - Setup (Figma: white card, radius 16, border 1px, padding 13, gap 9)
    private func setupStatusContainerView() {
        Statuscontainerview.backgroundColor = .white
        Statuscontainerview.layer.cornerRadius = 16
        Statuscontainerview.layer.borderWidth = 1
        Statuscontainerview.layer.borderColor = UIColor(red: 0.90, green: 0.91, blue: 0.93, alpha: 1).cgColor
        Statuscontainerview.clipsToBounds = true

        Statuscontainerview.addSubview(activityTitleLabel)
        Statuscontainerview.addSubview(followingImageView)
        Statuscontainerview.addSubview(followingLabel)
        Statuscontainerview.addSubview(firstTimelineItem)
        Statuscontainerview.addSubview(secondTimelineItem)
        Statuscontainerview.addSubview(connectorLineView)

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
            followingImageView.heightAnchor.constraint(equalToConstant: 16),

            // First timeline item
            firstTimelineItem.topAnchor.constraint(equalTo: activityTitleLabel.bottomAnchor, constant: 14),
            firstTimelineItem.leadingAnchor.constraint(equalTo: Statuscontainerview.leadingAnchor, constant: 13),
            firstTimelineItem.trailingAnchor.constraint(equalTo: Statuscontainerview.trailingAnchor, constant: -13),

            // Second timeline item (gap 9 per Figma)
            secondTimelineItem.topAnchor.constraint(equalTo: firstTimelineItem.bottomAnchor, constant: 9),
            secondTimelineItem.leadingAnchor.constraint(equalTo: Statuscontainerview.leadingAnchor, constant: 13),
            secondTimelineItem.trailingAnchor.constraint(equalTo: Statuscontainerview.trailingAnchor, constant: -13),
            secondTimelineItem.bottomAnchor.constraint(equalTo: Statuscontainerview.bottomAnchor, constant: -13),

            // Connector line: joins blue dot -> blue dot
            connectorLineView.centerXAnchor.constraint(equalTo: firstTimelineItem.dotCenterXAnchor),
            connectorLineView.widthAnchor.constraint(equalToConstant: 2),
            connectorLineView.topAnchor.constraint(equalTo: firstTimelineItem.dotBottomAnchor, constant: 4),
            connectorLineView.bottomAnchor.constraint(equalTo: secondTimelineItem.dotTopAnchor, constant: -4)
        ])
    }

    // MARK: - Public update (for API later)
    func configureActivity(
        firstTitle: String, firstSubtitle: String,
        secondTitle: String, secondSubtitle: String
    ) {
        firstTimelineItem.update(title: firstTitle, subtitle: firstSubtitle)
        secondTimelineItem.update(title: secondTitle, subtitle: secondSubtitle)
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
