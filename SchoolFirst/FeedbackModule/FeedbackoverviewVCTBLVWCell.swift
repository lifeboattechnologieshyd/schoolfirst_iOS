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
    
    @IBOutlet weak var Createnewfeedbackbutton: UIButton!
    
    // MARK: - Filter Type
    enum FeedbackFilter: String {
        case all = "ALL"
        case pending = "PENDING"
        case inReview = "IN REVIEW"
        case resolved = "RESOLVED"
    }
    
    // MARK: - Closures
    var onCreateNewFeedbackTapped: (() -> Void)?
    var onFilterSelected: ((FeedbackFilter) -> Void)?
    
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
    
    // MARK: - Current Selected Filter
    private var currentFilter: FeedbackFilter = .all
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        setupStatusCards()
        setupFilterButtons()
        setupStatusCardTapGestures()
        
        // Wire up the Create New Feedback button
        Createnewfeedbackbutton.addTarget(self, action: #selector(createNewFeedbackTapped), for: .touchUpInside)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Button Action
    @objc private func createNewFeedbackTapped() {
        onCreateNewFeedbackTapped?()
    }
    
    // MARK: - Setup Status Cards
    private func setupStatusCards() {
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
        
        pendingCard.configure(
            title: "PENDING",
            count: "0",
            dotColor: UIColor(red: 1.0, green: 0.62, blue: 0.11, alpha: 1.0),
            progress: 0.0,
            progressColor: UIColor(red: 1.0, green: 0.62, blue: 0.11, alpha: 1.0)
        )
        
        inReviewCard.configure(
            title: "IN REVIEW",
            count: "0",
            dotColor: UIColor(red: 0.25, green: 0.47, blue: 0.95, alpha: 1.0),
            progress: 0.0,
            progressColor: UIColor(red: 0.25, green: 0.47, blue: 0.95, alpha: 1.0)
        )
        
        resolvedCard.configure(
            title: "RESOLVED",
            count: "0",
            dotColor: UIColor(red: 0.20, green: 0.78, blue: 0.35, alpha: 1.0),
            progress: 0.0,
            progressColor: UIColor(red: 0.20, green: 0.78, blue: 0.35, alpha: 1.0)
        )
        
        stackView.addArrangedSubview(pendingCard)
        stackView.addArrangedSubview(inReviewCard)
        stackView.addArrangedSubview(resolvedCard)
    }
    
    // MARK: - Tap Gestures on Status Cards
    private func setupStatusCardTapGestures() {
        let pendingTap = UITapGestureRecognizer(target: self, action: #selector(pendingCardTapped))
        pendingCard.isUserInteractionEnabled = true
        pendingCard.addGestureRecognizer(pendingTap)
        
        let inReviewTap = UITapGestureRecognizer(target: self, action: #selector(inReviewCardTapped))
        inReviewCard.isUserInteractionEnabled = true
        inReviewCard.addGestureRecognizer(inReviewTap)
        
        let resolvedTap = UITapGestureRecognizer(target: self, action: #selector(resolvedCardTapped))
        resolvedCard.isUserInteractionEnabled = true
        resolvedCard.addGestureRecognizer(resolvedTap)
    }
    
    @objc private func pendingCardTapped() {
        applyFilter(.pending)
    }
    
    @objc private func inReviewCardTapped() {
        applyFilter(.inReview)
    }
    
    @objc private func resolvedCardTapped() {
        applyFilter(.resolved)
    }
    
    // MARK: - Setup Filter Buttons
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
        
        styleFilterButton(
            allButton,
            title: " All 0",
            titleColor: UIColor(red: 0.40, green: 0.45, blue: 0.52, alpha: 1.0),
            bgColor: UIColor(red: 0.95, green: 0.96, blue: 0.98, alpha: 1.0),
            icon: "line.3.horizontal.decrease"
        )
        
        styleFilterButton(
            pendingFilterButton,
            title: "Pending",
            titleColor: UIColor(red: 0.85, green: 0.52, blue: 0.05, alpha: 1.0),
            bgColor: UIColor(red: 1.0, green: 0.95, blue: 0.85, alpha: 1.0)
        )
        
        styleFilterButton(
            inReviewFilterButton,
            title: "In Review",
            titleColor: UIColor(red: 0.25, green: 0.47, blue: 0.95, alpha: 1.0),
            bgColor: UIColor(red: 0.90, green: 0.93, blue: 1.0, alpha: 1.0)
        )
        
        styleFilterButton(
            resolvedFilterButton,
            title: "Resolved",
            titleColor: UIColor(red: 0.15, green: 0.65, blue: 0.30, alpha: 1.0),
            bgColor: UIColor(red: 0.88, green: 0.97, blue: 0.90, alpha: 1.0)
        )
        
        // Add target actions
        allButton.addTarget(self, action: #selector(allFilterTapped), for: .touchUpInside)
        pendingFilterButton.addTarget(self, action: #selector(pendingFilterTapped), for: .touchUpInside)
        inReviewFilterButton.addTarget(self, action: #selector(inReviewFilterTapped), for: .touchUpInside)
        resolvedFilterButton.addTarget(self, action: #selector(resolvedFilterTapped), for: .touchUpInside)
        
        filterStackView.addArrangedSubview(allButton)
        filterStackView.addArrangedSubview(pendingFilterButton)
        filterStackView.addArrangedSubview(inReviewFilterButton)
        filterStackView.addArrangedSubview(resolvedFilterButton)
    }
    
    private func styleFilterButton(_ button: UIButton, title: String, titleColor: UIColor, bgColor: UIColor, icon: String? = nil) {
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
    
    // MARK: - Filter Button Actions
    @objc private func allFilterTapped() {
        applyFilter(.all)
    }
    
    @objc private func pendingFilterTapped() {
        applyFilter(.pending)
    }
    
    @objc private func inReviewFilterTapped() {
        applyFilter(.inReview)
    }
    
    @objc private func resolvedFilterTapped() {
        applyFilter(.resolved)
    }
    
    // MARK: - Apply Filter + Visual Update
    private func applyFilter(_ filter: FeedbackFilter) {
        currentFilter = filter
        updateFilterButtonSelection(filter)
        onFilterSelected?(filter)
    }
    
    private func updateFilterButtonSelection(_ selected: FeedbackFilter) {
        // Reset all to default
        allButton.layer.borderWidth = 0
        pendingFilterButton.layer.borderWidth = 0
        inReviewFilterButton.layer.borderWidth = 0
        resolvedFilterButton.layer.borderWidth = 0
        
        // Highlight selected with a border
        switch selected {
        case .all:
            allButton.layer.borderWidth = 2
            allButton.layer.borderColor = UIColor(red: 0.40, green: 0.45, blue: 0.52, alpha: 1.0).cgColor
        case .pending:
            pendingFilterButton.layer.borderWidth = 2
            pendingFilterButton.layer.borderColor = UIColor(red: 0.85, green: 0.52, blue: 0.05, alpha: 1.0).cgColor
        case .inReview:
            inReviewFilterButton.layer.borderWidth = 2
            inReviewFilterButton.layer.borderColor = UIColor(red: 0.25, green: 0.47, blue: 0.95, alpha: 1.0).cgColor
        case .resolved:
            resolvedFilterButton.layer.borderWidth = 2
            resolvedFilterButton.layer.borderColor = UIColor(red: 0.15, green: 0.65, blue: 0.30, alpha: 1.0).cgColor
        }
    }
    
    /// Call this with real API counts
    func updateCounts(pending: Int, inReview: Int, resolved: Int) {
        let total = max(pending + inReview + resolved, 1)
        
        pendingCard.update(
            count: "\(pending)",
            progress: CGFloat(pending) / CGFloat(total)
        )
        
        inReviewCard.update(
            count: "\(inReview)",
            progress: CGFloat(inReview) / CGFloat(total)
        )
        
        resolvedCard.update(
            count: "\(resolved)",
            progress: CGFloat(resolved) / CGFloat(total)
        )
        
        allButton.setTitle(" All \(pending + inReview + resolved)", for: .normal)
    }
    
    /// Call to programmatically set the selected filter visual (e.g., when VC resets)
    func setSelectedFilter(_ filter: FeedbackFilter) {
        currentFilter = filter
        updateFilterButtonSelection(filter)
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
            
            titleLabel.font = .systemFont(ofSize: 11, weight: .semibold)
            titleLabel.textColor = UIColor(red: 0.45, green: 0.50, blue: 0.56, alpha: 1.0)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            addSubview(titleLabel)
            
            dotView.layer.cornerRadius = 4
            dotView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(dotView)
            
            countLabel.font = .systemFont(ofSize: 28, weight: .bold)
            countLabel.textColor = UIColor(red: 0.12, green: 0.16, blue: 0.22, alpha: 1.0)
            countLabel.translatesAutoresizingMaskIntoConstraints = false
            addSubview(countLabel)
            
            progressTrack.backgroundColor = UIColor(red: 0.93, green: 0.94, blue: 0.96, alpha: 1.0)
            progressTrack.layer.cornerRadius = 2
            progressTrack.translatesAutoresizingMaskIntoConstraints = false
            addSubview(progressTrack)
            
            progressBar.layer.cornerRadius = 2
            progressBar.translatesAutoresizingMaskIntoConstraints = false
            progressTrack.addSubview(progressBar)
            
            progressWidthConstraint = progressBar.widthAnchor.constraint(equalToConstant: 0)
            
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 14),
                titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
                
                dotView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
                dotView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 6),
                dotView.widthAnchor.constraint(equalToConstant: 8),
                dotView.heightAnchor.constraint(equalToConstant: 8),
                dotView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -12),
                
                countLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
                countLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
                countLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
                
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
    }
}
