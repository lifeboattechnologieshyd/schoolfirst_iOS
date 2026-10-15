//
//  RemarksTBLVCll1.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 15/10/26.
//

import UIKit

class RemarksTBLVCll1: UITableViewCell {

    @IBOutlet weak var cantainerview: UIView!
    @IBOutlet weak var cantainerview2: UIView!

    // MARK: - Cards
    private let academicCard = RemarkSummaryCardView()
    private let behaviourCard = RemarkSummaryCardView()
    private let newCard = RemarkSummaryCardView()
    private let stackView = UIStackView()

    // MARK: - Filter Buttons
    private let filterStackView = UIStackView()
    private let allButton = UIButton(type: .system)
    private let appreciationButton = UIButton(type: .system)
    private let academicButton = UIButton(type: .system)
    private let behaviourButton = UIButton(type: .system)

    private var selectedFilterButton: UIButton?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupContainerView()
        setupCards()
        configureCards()
        setupFilterButtons()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: - Setup Container
    private func setupContainerView() {
        cantainerview.backgroundColor = .clear
        cantainerview2.backgroundColor = .clear
    }

    // MARK: - Setup Cards Layout
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

    // MARK: - Configure Cards
    private func configureCards() {
        academicCard.configure(
            title: "ACADEMIC",
            count: "3",
            dotColor: UIColor(red: 0.25, green: 0.47, blue: 0.95, alpha: 1.0),
            progress: 0.35,
            progressColor: UIColor(red: 0.25, green: 0.47, blue: 0.95, alpha: 1.0)
        )

        behaviourCard.configure(
            title: "BEHAVIOUR",
            count: "1",
            dotColor: UIColor(red: 0.96, green: 0.65, blue: 0.10, alpha: 1.0),
            progress: 0.18,
            progressColor: UIColor(red: 0.96, green: 0.65, blue: 0.10, alpha: 1.0)
        )

        newCard.configure(
            title: "NEW",
            count: "2",
            dotColor: UIColor(red: 0.18, green: 0.73, blue: 0.42, alpha: 1.0),
            progress: 0.28,
            progressColor: UIColor(red: 0.18, green: 0.73, blue: 0.42, alpha: 1.0)
        )
    }

    // MARK: - Setup Filter Buttons like Figma
    private func setupFilterButtons() {
        filterStackView.axis = .horizontal
        filterStackView.alignment = .fill
        filterStackView.distribution = .fill
        filterStackView.spacing = 8
        filterStackView.translatesAutoresizingMaskIntoConstraints = false

        cantainerview2.addSubview(filterStackView)

        NSLayoutConstraint.activate([
            filterStackView.topAnchor.constraint(equalTo: cantainerview2.topAnchor),
            filterStackView.leadingAnchor.constraint(equalTo: cantainerview2.leadingAnchor),
            filterStackView.trailingAnchor.constraint(lessThanOrEqualTo: cantainerview2.trailingAnchor),
            filterStackView.bottomAnchor.constraint(equalTo: cantainerview2.bottomAnchor),
            filterStackView.heightAnchor.constraint(equalToConstant: 34)
        ])

        configureFilterButton(
            allButton,
            title: "All 9",
            iconName: "line.3.horizontal.decrease",
            selected: true
        )

        configureFilterButton(
            appreciationButton,
            title: "Appreciation",
            iconName: nil,
            selected: false
        )

        configureFilterButton(
            academicButton,
            title: "Academic",
            iconName: nil,
            selected: false
        )

        configureFilterButton(
            behaviourButton,
            title: "Behaviour",
            iconName: nil,
            selected: false
        )

        allButton.addTarget(self, action: #selector(filterButtonTapped(_:)), for: .touchUpInside)
        appreciationButton.addTarget(self, action: #selector(filterButtonTapped(_:)), for: .touchUpInside)
        academicButton.addTarget(self, action: #selector(filterButtonTapped(_:)), for: .touchUpInside)
        behaviourButton.addTarget(self, action: #selector(filterButtonTapped(_:)), for: .touchUpInside)

        filterStackView.addArrangedSubview(allButton)
        filterStackView.addArrangedSubview(appreciationButton)
        filterStackView.addArrangedSubview(academicButton)
        filterStackView.addArrangedSubview(behaviourButton)

        // Figma-like exact widths to fit one line
        allButton.translatesAutoresizingMaskIntoConstraints = false
        appreciationButton.translatesAutoresizingMaskIntoConstraints = false
        academicButton.translatesAutoresizingMaskIntoConstraints = false
        behaviourButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            allButton.widthAnchor.constraint(equalToConstant: 56),
            appreciationButton.widthAnchor.constraint(equalToConstant: 106),
            academicButton.widthAnchor.constraint(equalToConstant: 84),
            behaviourButton.widthAnchor.constraint(equalToConstant: 88),

            allButton.heightAnchor.constraint(equalToConstant: 34),
            appreciationButton.heightAnchor.constraint(equalToConstant: 34),
            academicButton.heightAnchor.constraint(equalToConstant: 34),
            behaviourButton.heightAnchor.constraint(equalToConstant: 34)
        ])

        selectedFilterButton = allButton
    }

    private func configureFilterButton(
        _ button: UIButton,
        title: String,
        iconName: String?,
        selected: Bool
    ) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(
            UIColor(red: 0.31, green: 0.38, blue: 0.50, alpha: 1.0),
            for: .normal
        )
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
        button.titleLabel?.lineBreakMode = .byClipping
        button.backgroundColor = selected
            ? UIColor(red: 0.94, green: 0.96, blue: 0.99, alpha: 1.0)
            : .white
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        button.contentEdgeInsets = UIEdgeInsets(top: 7, left: 10, bottom: 7, right: 10)

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
    }

    private func updateSelectedFilter(_ button: UIButton) {
        let buttons = [allButton, appreciationButton, academicButton, behaviourButton]

        for item in buttons {
            item.backgroundColor = .white
            item.layer.borderWidth = 0
            item.layer.borderColor = UIColor.clear.cgColor
        }

        button.backgroundColor = UIColor(red: 0.94, green: 0.96, blue: 0.99, alpha: 1.0)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(red: 0.82, green: 0.87, blue: 0.95, alpha: 1.0).cgColor

        selectedFilterButton = button
    }

    // MARK: - Optional Dynamic Update
    func updateCounts(academic: Int, behaviour: Int, newCount: Int) {
        let total = max(academic + behaviour + newCount, 1)

        academicCard.update(
            count: "\(academic)",
            progress: CGFloat(academic) / CGFloat(total)
        )

        behaviourCard.update(
            count: "\(behaviour)",
            progress: CGFloat(behaviour) / CGFloat(total)
        )

        newCard.update(
            count: "\(newCount)",
            progress: CGFloat(newCount) / CGFloat(total)
        )
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

    func configure(
        title: String,
        count: String,
        dotColor: UIColor,
        progress: CGFloat,
        progressColor: UIColor
    ) {
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
