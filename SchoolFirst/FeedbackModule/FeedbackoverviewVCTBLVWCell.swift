//
//  FeedbackoverviewVCTBLVWCell.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 12/10/26.
//

import UIKit

class FeedbackoverviewVCTBLVWCell: UITableViewCell {

    @IBOutlet weak var Containerview: UIView!
    @IBOutlet weak var Containerview2: UIView!
    
    // MARK: - Status Card Views
    private let pendingCard = StatusCardView()
    private let inReviewCard = StatusCardView()
    private let resolvedCard = StatusCardView()
    private let stackView = UIStackView()
    
    // MARK: - Filter Buttons (Containerview2)
    private let filterStackView = UIStackView()
    private let allButton = UIButton(type: .system)
    private let pendingFilterButton = UIButton(type: .system)
    private let inReviewFilterButton = UIButton(type: .system)
    private let resolvedFilterButton = UIButton(type: .system)

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        setupStatusCards()
        setupFilterButtons()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: - Setup Status Cards
    private func setupStatusCards() {
        // Stack View – 3 equal cards side by side
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        Containerview.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: Containerview.topAnchor, constant: 4),
            stackView.leadingAnchor.constraint(equalTo: Containerview.leadingAnchor, constant: 4),
            stackView.trailingAnchor.constraint(equalTo: Containerview.trailingAnchor, constant: -4),
            stackView.bottomAnchor.constraint(equalTo: Containerview.bottomAnchor, constant: -4)
        ])

        // Configure each card (Figma colors)
        pendingCard.configure(
            title: "PENDING",
            count: "2",
            dotColor: UIColor(red: 1.0, green: 0.62, blue: 0.11, alpha: 1.0),      // Orange
            progress: 0.35,
            progressColor: UIColor(red: 1.0, green: 0.62, blue: 0.11, alpha: 1.0)
        )

        inReviewCard.configure(
            title: "IN REVIEW",
            count: "1",
            dotColor: UIColor(red: 0.25, green: 0.47, blue: 0.95, alpha: 1.0),    // Blue
            progress: 0.20,
            progressColor: UIColor(red: 0.25, green: 0.47, blue: 0.95, alpha: 1.0)
        )

        resolvedCard.configure(
            title: "RESOLVED",
            count: "5",
            dotColor: UIColor(red: 0.20, green: 0.78, blue: 0.35, alpha: 1.0),    // Green
            progress: 0.70,
            progressColor: UIColor(red: 0.20, green: 0.78, blue: 0.35, alpha: 1.0)
        )

        stackView.addArrangedSubview(pendingCard)
        stackView.addArrangedSubview(inReviewCard)
        stackView.addArrangedSubview(resolvedCard)
    }
    
    // MARK: - Setup Filter Buttons (Containerview2) – Figma backgrounds
    private func setupFilterButtons() {
        filterStackView.axis = .horizontal
        filterStackView.distribution = .fillProportionally
        filterStackView.alignment = .fill
        filterStackView.spacing = 7
        filterStackView.translatesAutoresizingMaskIntoConstraints = false
        Containerview2.addSubview(filterStackView)

        NSLayoutConstraint.activate([
            filterStackView.topAnchor.constraint(equalTo: Containerview2.topAnchor),
            filterStackView.leadingAnchor.constraint(equalTo: Containerview2.leadingAnchor),
            filterStackView.trailingAnchor.constraint(equalTo: Containerview2.trailingAnchor),
            filterStackView.bottomAnchor.constraint(equalTo: Containerview2.bottomAnchor),
            filterStackView.heightAnchor.constraint(equalToConstant: 32)
        ])

        // Helper to style pill buttons
        func styleFilterButton(_ button: UIButton, title: String, titleColor: UIColor, bgColor: UIColor, icon: String? = nil) {
            button.setTitle(title, for: .normal)
            button.setTitleColor(titleColor, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
            button.backgroundColor = bgColor
            button.layer.cornerRadius = 8
            button.clipsToBounds = true
            button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
            
            if let iconName = icon {
                let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
                button.setImage(UIImage(systemName: iconName, withConfiguration: config), for: .normal)
                button.tintColor = titleColor
                button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -2, bottom: 0, right: 2)
            }
        }

        // 1. All 8 – light gray background (Figma)
        styleFilterButton(
            allButton,
            title: " All 8",
            titleColor: UIColor(red: 0.40, green: 0.45, blue: 0.52, alpha: 1.0),
            bgColor: UIColor(red: 0.95, green: 0.96, blue: 0.98, alpha: 1.0),
            icon: "line.3.horizontal.decrease"
        )

        // 2. Pending – soft cream/yellow background (Figma)
        styleFilterButton(
            pendingFilterButton,
            title: "Pending",
            titleColor: UIColor(red: 0.85, green: 0.52, blue: 0.05, alpha: 1.0),
            bgColor: UIColor(red: 1.0, green: 0.95, blue: 0.85, alpha: 1.0)
        )

        // 3. In Review – soft blue background (Figma)
        styleFilterButton(
            inReviewFilterButton,
            title: "In Review",
            titleColor: UIColor(red: 0.25, green: 0.47, blue: 0.95, alpha: 1.0),
            bgColor: UIColor(red: 0.90, green: 0.93, blue: 1.0, alpha: 1.0)
        )

        // 4. Resolved – soft green background (Figma)
        styleFilterButton(
            resolvedFilterButton,
            title: "Resolved",
            titleColor: UIColor(red: 0.15, green: 0.65, blue: 0.30, alpha: 1.0),
            bgColor: UIColor(red: 0.88, green: 0.97, blue: 0.90, alpha: 1.0)
        )

        filterStackView.addArrangedSubview(allButton)
        filterStackView.addArrangedSubview(pendingFilterButton)
        filterStackView.addArrangedSubview(inReviewFilterButton)
        filterStackView.addArrangedSubview(resolvedFilterButton)
    }

    /// Call this later when you have real API counts
    func updateCounts(pending: Int, inReview: Int, resolved: Int) {
        let total = max(pending + inReview + resolved, 1)
        pendingCard.update(count: "\(pending)", progress: CGFloat(pending) / CGFloat(total))
        inReviewCard.update(count: "\(inReview)", progress: CGFloat(inReview) / CGFloat(total))
        resolvedCard.update(count: "\(resolved)", progress: CGFloat(resolved) / CGFloat(total))
        
        allButton.setTitle(" All \(total)", for: .normal)
    }
}

// MARK: - Reusable Status Card View
private class StatusCardView: UIView {

    private let titleLabel = UILabel()
    private let dotView = UIView()
    private let countLabel = UILabel()
    private let progressTrack = UIView()
    private let progressBar = UIView()
    private var progressWidthConstraint: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor(red: 0.90, green: 0.92, blue: 0.95, alpha: 1.0).cgColor
        clipsToBounds = true

        // Title
        titleLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        titleLabel.textColor = UIColor(red: 0.45, green: 0.50, blue: 0.56, alpha: 1.0)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        // Colored Dot
        dotView.layer.cornerRadius = 4
        dotView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(dotView)

        // Count Number
        countLabel.font = .systemFont(ofSize: 28, weight: .bold)
        countLabel.textColor = UIColor(red: 0.12, green: 0.16, blue: 0.22, alpha: 1.0)
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(countLabel)

        // Progress Track (background)
        progressTrack.backgroundColor = UIColor(red: 0.93, green: 0.94, blue: 0.96, alpha: 1.0)
        progressTrack.layer.cornerRadius = 2
        progressTrack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(progressTrack)

        // Progress Bar (fill)
        progressBar.layer.cornerRadius = 2
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressTrack.addSubview(progressBar)

        progressWidthConstraint = progressBar.widthAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            // Title + Dot row
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),

            dotView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            dotView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 6),
            dotView.widthAnchor.constraint(equalToConstant: 8),
            dotView.heightAnchor.constraint(equalToConstant: 8),
            dotView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -12),

            // Count
            countLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            countLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            countLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),

            // Progress
            progressTrack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            progressTrack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            progressTrack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14),
            progressTrack.heightAnchor.constraint(equalToConstant: 4),

            progressBar.leadingAnchor.constraint(equalTo: progressTrack.leadingAnchor),
            progressBar.topAnchor.constraint(equalTo: progressTrack.topAnchor),
            progressBar.bottomAnchor.constraint(equalTo: progressTrack.bottomAnchor),
            progressWidthConstraint!
        ])
    }

    func configure(title: String, count: String, dotColor: UIColor, progress: CGFloat, progressColor: UIColor) {
        titleLabel.text = title
        countLabel.text = count
        dotView.backgroundColor = dotColor
        progressBar.backgroundColor = progressColor
        updateProgress(progress)
    }

    func update(count: String, progress: CGFloat) {
        countLabel.text = count
        updateProgress(progress)
    }

    private func updateProgress(_ value: CGFloat) {
        layoutIfNeeded()
        let clamped = max(0, min(value, 1))
        let fullWidth = progressTrack.bounds.width > 0
            ? progressTrack.bounds.width
            : (UIScreen.main.bounds.width - 64) / 3 - 24
        progressWidthConstraint?.constant = fullWidth * clamped
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let text = countLabel.text, let _ = Int(text) {
            let current = progressWidthConstraint?.constant ?? 0
            let full = progressTrack.bounds.width
            if full > 0 && current == 0 {
                // keep existing ratio if already set via configure
            }
        }
    }
}
