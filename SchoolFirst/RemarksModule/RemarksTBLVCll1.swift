//
//  RemarksTBLVCll1.swift
//  SchoolFirst
//

import UIKit

class RemarksTBLVCll1: UITableViewCell {

    @IBOutlet weak var cantainerview: UIView!
    @IBOutlet weak var cantainerview2: UIView!
    @IBOutlet weak var FilterButton: UIButton!

    var onFilterButtonTapped: (() -> Void)?
    var onCategorySelected: ((String) -> Void)?

    private let academicCard = RemarkSummaryCardView()
    private let behaviourCard = RemarkSummaryCardView()
    private let newCard = RemarkSummaryCardView()
    private let stackView = UIStackView()

    private let scrollView = UIScrollView()
    private let filterStackView = UIStackView()
    private var filterButtons: [UIButton] = []
    private var categories: [FeedbackCategoryOption] = []
    private var totalCount: Int = 0
    private var selectedFilterButton: UIButton?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupContainerView()
        setupCards()
        configureCards()
        setupFilterScrollView()
        FilterButton.addTarget(self, action: #selector(mainFilterButtonTapped), for: .touchUpInside)
    }

    @objc private func mainFilterButtonTapped() {
        onFilterButtonTapped?()
    }

    private func setupContainerView() {
        cantainerview.backgroundColor = .clear
        cantainerview2.backgroundColor = .clear
    }

    private func setupCards() {
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        cantainerview.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: cantainerview.topAnchor, constant: 6),
            stackView.leadingAnchor.constraint(equalTo: cantainerview.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: cantainerview.trailingAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 84)
        ])

        stackView.addArrangedSubview(academicCard)
        stackView.addArrangedSubview(behaviourCard)
        stackView.addArrangedSubview(newCard)
    }

    private func configureCards() {
        academicCard.configure(
            title: "ACADEMIC", count: "0",
            dotColor: UIColor(red: 0.25, green: 0.47, blue: 0.95, alpha: 1.0),
            progress: 0,
            progressColor: UIColor(red: 0.25, green: 0.47, blue: 0.95, alpha: 1.0)
        )
        behaviourCard.configure(
            title: "BEHAVIOUR", count: "0",
            dotColor: UIColor(red: 0.96, green: 0.65, blue: 0.10, alpha: 1.0),
            progress: 0,
            progressColor: UIColor(red: 0.96, green: 0.65, blue: 0.10, alpha: 1.0)
        )
        newCard.configure(
            title: "NEW", count: "0",
            dotColor: UIColor(red: 0.18, green: 0.73, blue: 0.42, alpha: 1.0),
            progress: 0,
            progressColor: UIColor(red: 0.18, green: 0.73, blue: 0.42, alpha: 1.0)
        )
    }

    private func setupFilterScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        cantainerview2.addSubview(scrollView)

        filterStackView.axis = .horizontal
        filterStackView.alignment = .center
        filterStackView.distribution = .fill
        filterStackView.spacing = 8
        filterStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(filterStackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: cantainerview2.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: cantainerview2.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: cantainerview2.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: cantainerview2.bottomAnchor),
            scrollView.heightAnchor.constraint(equalToConstant: 34),

            filterStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            filterStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            filterStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            filterStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            filterStackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
    }

    func configureCategories(
        _ categories: [FeedbackCategoryOption],
        totalCount: Int,
        selectedCategoryId: String
    ) {
        let currentIds = self.categories.map { $0.id }
        let newIds = categories.map { $0.id }

        // Same data → only update selection highlight (keeps scroll position)
        if currentIds == newIds && self.totalCount == totalCount && !filterButtons.isEmpty {
            for (index, button) in filterButtons.enumerated() {
                if index < categories.count, categories[index].id == selectedCategoryId {
                    updateSelectedFilter(button)
                }
            }
            return
        }

        self.categories = categories
        self.totalCount = totalCount
        clearFilterButtons()

        guard !categories.isEmpty else {
            let allButton = UIButton(type: .system)
            configureFilterButton(allButton, title: "All", iconName: "line.3.horizontal.decrease", selected: true)
            allButton.tag = 0
            allButton.addTarget(self, action: #selector(filterButtonTapped(_:)), for: .touchUpInside)
            filterStackView.addArrangedSubview(allButton)
            filterButtons.append(allButton)
            selectedFilterButton = allButton
            return
        }

        for (index, category) in categories.enumerated() {
            let button = UIButton(type: .system)
            let isAll = category.id == "all" || category.name.lowercased() == "all"
            let title = isAll ? "All \(totalCount)" : category.name
            let isSelected = (category.id == selectedCategoryId)

            configureFilterButton(
                button,
                title: title,
                iconName: isAll ? "line.3.horizontal.decrease" : nil,
                selected: isSelected
            )
            button.tag = index
            button.addTarget(self, action: #selector(filterButtonTapped(_:)), for: .touchUpInside)
            filterStackView.addArrangedSubview(button)
            filterButtons.append(button)

            if isSelected { selectedFilterButton = button }
        }
    }

    private func clearFilterButtons() {
        for button in filterButtons {
            filterStackView.removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        filterButtons.removeAll()
        selectedFilterButton = nil
    }

    private func configureFilterButton(
        _ button: UIButton,
        title: String,
        iconName: String?,
        selected: Bool
    ) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor(red: 0.31, green: 0.38, blue: 0.50, alpha: 1.0), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
        button.titleLabel?.lineBreakMode = .byClipping
        button.backgroundColor = selected
            ? UIColor(red: 0.94, green: 0.96, blue: 0.99, alpha: 1.0)
            : .white
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        button.contentEdgeInsets = UIEdgeInsets(top: 7, left: 10, bottom: 7, right: 10)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 34).isActive = true

        if selected {
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor(red: 0.82, green: 0.87, blue: 0.95, alpha: 1.0).cgColor
        } else {
            button.layer.borderWidth = 0
            button.layer.borderColor = UIColor.clear.cgColor
        }

        if let iconName = iconName {
            let config = UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
            button.setImage(UIImage(systemName: iconName, withConfiguration: config), for: .normal)
            button.tintColor = UIColor(red: 0.31, green: 0.38, blue: 0.50, alpha: 1.0)
            button.semanticContentAttribute = .forceLeftToRight
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        } else {
            button.setImage(nil, for: .normal)
        }
    }

    @objc private func filterButtonTapped(_ sender: UIButton) {
        updateSelectedFilter(sender)
        let idx = sender.tag
        if idx >= 0 && idx < categories.count {
            onCategorySelected?(categories[idx].id)
        }
    }

    private func updateSelectedFilter(_ button: UIButton) {
        for item in filterButtons {
            item.backgroundColor = .white
            item.layer.borderWidth = 0
            item.layer.borderColor = UIColor.clear.cgColor
        }
        button.backgroundColor = UIColor(red: 0.94, green: 0.96, blue: 0.99, alpha: 1.0)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(red: 0.82, green: 0.87, blue: 0.95, alpha: 1.0).cgColor
        selectedFilterButton = button
    }

    func updateCounts(academic: Int, behaviour: Int, newCount: Int) {
        let total = max(academic + behaviour + newCount, 1)
        academicCard.update(count: "\(academic)", progress: CGFloat(academic) / CGFloat(total))
        behaviourCard.update(count: "\(behaviour)", progress: CGFloat(behaviour) / CGFloat(total))
        newCard.update(count: "\(newCount)", progress: CGFloat(newCount) / CGFloat(total))
    }
}

// MARK: - Summary Card View
private class RemarkSummaryCardView: UIView {

    private let titleLabel = UILabel()
    private let dotView = UIView()
    private let countLabel = UILabel()
    private let progressTrack = UIView()
    private let progressBar = UIView()
    private var progressWidthConstraint: NSLayoutConstraint?
    private var currentProgress: CGFloat = 0

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
        layer.cornerRadius = 18
        layer.borderWidth = 1
        layer.borderColor = UIColor(red: 0.87, green: 0.90, blue: 0.95, alpha: 1.0).cgColor
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        titleLabel.textColor = UIColor(red: 0.45, green: 0.50, blue: 0.56, alpha: 1.0)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        dotView.layer.cornerRadius = 5
        dotView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(dotView)

        countLabel.font = .systemFont(ofSize: 26, weight: .bold)
        countLabel.textColor = UIColor(red: 0.14, green: 0.18, blue: 0.26, alpha: 1.0)
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(countLabel)

        progressTrack.backgroundColor = UIColor(red: 0.93, green: 0.94, blue: 0.96, alpha: 1.0)
        progressTrack.layer.cornerRadius = 3
        progressTrack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(progressTrack)

        progressBar.layer.cornerRadius = 3
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressTrack.addSubview(progressBar)
        progressWidthConstraint = progressBar.widthAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            dotView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            dotView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            dotView.widthAnchor.constraint(equalToConstant: 10),
            dotView.heightAnchor.constraint(equalToConstant: 10),
            countLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            countLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            countLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            progressTrack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            progressTrack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            progressTrack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14),
            progressTrack.heightAnchor.constraint(equalToConstant: 6),
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
        currentProgress = max(0, min(progress, 1))
        setNeedsLayout()
        layoutIfNeeded()
        updateProgressWidth()
    }

    func update(count: String, progress: CGFloat) {
        countLabel.text = count
        currentProgress = max(0, min(progress, 1))
        setNeedsLayout()
        layoutIfNeeded()
        updateProgressWidth()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateProgressWidth()
    }

    private func updateProgressWidth() {
        let fullWidth = progressTrack.bounds.width
        guard fullWidth > 0 else { return }
        progressWidthConstraint?.constant = fullWidth * currentProgress
    }
}
