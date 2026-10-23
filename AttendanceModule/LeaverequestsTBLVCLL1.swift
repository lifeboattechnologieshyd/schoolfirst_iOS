//
//  LeaverequestsTBLVCLL1.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 21/10/26.
//

import UIKit

class LeaverequestsTBLVCLL1: UITableViewCell {

    @IBOutlet weak var NumberofrequestsLabel: UILabel!
    @IBOutlet weak var Termanddatelabel: UILabel!
    @IBOutlet weak var AcademicyearLabel: UILabel!
    @IBOutlet weak var Cantainerview2: UIView!
    @IBOutlet weak var Cantainerview: UIView!

    private let filterScrollView = UIScrollView()
    private let filterStackView = UIStackView()
    private var filterButtons: [UIButton] = []

    private var pendingCountLabel: UILabel?
    private var approvedCountLabel: UILabel?
    private var rejectedCountLabel: UILabel?

    private var selectedFilter = "All"

    var onFilterSelected: ((String) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        Cantainerview.backgroundColor = .clear
        Cantainerview2.backgroundColor = .clear

        setupSummaryCards()
        setupFilterTabs()
    }

    func configure(
        totalRequests: Int,
        pendingCount: Int,
        approvedCount: Int,
        rejectedCount: Int,
        academicYear: String,
        term: String,
        selectedFilter: String
    ) {
        // Populating the default storyboard label
        NumberofrequestsLabel.text = "\(totalRequests) requests"
        
        AcademicyearLabel.text = academicYear
        Termanddatelabel.text = term

        pendingCountLabel?.text = "\(pendingCount)"
        approvedCountLabel?.text = "\(approvedCount)"
        rejectedCountLabel?.text = "\(rejectedCount)"

        self.selectedFilter = selectedFilter

        Cantainerview.backgroundColor = .clear
        Cantainerview2.backgroundColor = .clear
        filterScrollView.backgroundColor = .clear
        filterStackView.backgroundColor = .clear

        updateFilterButtonStyles()
    }

    // MARK: - Summary Cards

    private func setupSummaryCards() {
        Cantainerview.subviews.forEach { $0.removeFromSuperview() }
        Cantainerview.backgroundColor = .clear

        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.backgroundColor = .clear
        stackView.translatesAutoresizingMaskIntoConstraints = false

        Cantainerview.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: Cantainerview.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: Cantainerview.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: Cantainerview.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: Cantainerview.bottomAnchor)
        ])

        let pendingCard = createSummaryCard(
            title: "Pending",
            countColor: UIColor(red: 0.72, green: 0.29, blue: 0.02, alpha: 1.0)
        )

        let approvedCard = createSummaryCard(
            title: "Approved",
            countColor: UIColor(red: 0.02, green: 0.45, blue: 0.25, alpha: 1.0)
        )

        let rejectedCard = createSummaryCard(
            title: "Rejected",
            countColor: UIColor(red: 0.72, green: 0.08, blue: 0.08, alpha: 1.0)
        )

        pendingCountLabel = pendingCard.countLabel
        approvedCountLabel = approvedCard.countLabel
        rejectedCountLabel = rejectedCard.countLabel

        stackView.addArrangedSubview(pendingCard.card)
        stackView.addArrangedSubview(approvedCard.card)
        stackView.addArrangedSubview(rejectedCard.card)
    }

    private func createSummaryCard(
        title: String,
        countColor: UIColor
    ) -> (card: UIView, countLabel: UILabel) {

        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 12
        card.layer.borderWidth = 1
        card.layer.borderColor =
            UIColor(red: 0.86, green: 0.89, blue: 0.94, alpha: 1).cgColor
        card.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor =
            UIColor(red: 0.40, green: 0.47, blue: 0.58, alpha: 1)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let countLabel = UILabel()
        countLabel.text = "0"
        countLabel.font = .systemFont(ofSize: 24, weight: .bold)
        countLabel.textColor = countColor
        countLabel.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(titleLabel)
        card.addSubview(countLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(
                equalTo: card.topAnchor,
                constant: 12
            ),
            titleLabel.leadingAnchor.constraint(
                equalTo: card.leadingAnchor,
                constant: 12
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: card.trailingAnchor,
                constant: -12
            ),

            countLabel.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: 6
            ),
            countLabel.leadingAnchor.constraint(
                equalTo: card.leadingAnchor,
                constant: 12
            ),
            countLabel.bottomAnchor.constraint(
                lessThanOrEqualTo: card.bottomAnchor,
                constant: -10
            )
        ])

        return (card, countLabel)
    }

    // MARK: - Filter Tabs

    private func setupFilterTabs() {
        Cantainerview2.subviews.forEach { $0.removeFromSuperview() }
        Cantainerview2.backgroundColor = .clear

        filterScrollView.backgroundColor = .clear
        filterScrollView.showsHorizontalScrollIndicator = false
        filterScrollView.translatesAutoresizingMaskIntoConstraints = false
        Cantainerview2.addSubview(filterScrollView)

        filterStackView.backgroundColor = .clear
        filterStackView.axis = .horizontal
        filterStackView.spacing = 8
        filterStackView.alignment = .fill
        filterStackView.distribution = .fillProportionally
        filterStackView.translatesAutoresizingMaskIntoConstraints = false
        filterScrollView.addSubview(filterStackView)

        NSLayoutConstraint.activate([
            filterScrollView.topAnchor.constraint(equalTo: Cantainerview2.topAnchor),
            filterScrollView.leadingAnchor.constraint(equalTo: Cantainerview2.leadingAnchor),
            filterScrollView.trailingAnchor.constraint(equalTo: Cantainerview2.trailingAnchor),
            filterScrollView.bottomAnchor.constraint(equalTo: Cantainerview2.bottomAnchor),

            filterStackView.topAnchor.constraint(
                equalTo: filterScrollView.contentLayoutGuide.topAnchor
            ),
            filterStackView.leadingAnchor.constraint(
                equalTo: filterScrollView.contentLayoutGuide.leadingAnchor
            ),
            filterStackView.trailingAnchor.constraint(
                equalTo: filterScrollView.contentLayoutGuide.trailingAnchor
            ),
            filterStackView.bottomAnchor.constraint(
                equalTo: filterScrollView.contentLayoutGuide.bottomAnchor
            ),
            filterStackView.heightAnchor.constraint(
                equalTo: filterScrollView.frameLayoutGuide.heightAnchor
            )
        ])

        let filterTitles = ["All", "Pending", "Approved", "Rejected"]

        for (index, title) in filterTitles.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
            button.layer.cornerRadius = 16
            button.tag = index
            button.contentEdgeInsets = UIEdgeInsets(
                top: 6,
                left: 16,
                bottom: 6,
                right: 16
            )
            button.addTarget(
                self,
                action: #selector(filterTapped(_:)),
                for: .touchUpInside
            )

            filterButtons.append(button)
            filterStackView.addArrangedSubview(button)
        }

        updateFilterButtonStyles()
    }

    @objc private func filterTapped(_ sender: UIButton) {
        guard let title = sender.title(for: .normal) else {
            return
        }

        selectedFilter = title
        updateFilterButtonStyles()
        onFilterSelected?(title)
    }

    private func updateFilterButtonStyles() {
        for button in filterButtons {
            let isSelected = button.title(for: .normal) == selectedFilter

            if isSelected {
                button.backgroundColor =
                    UIColor(red: 0.86, green: 0.94, blue: 1.0, alpha: 1.0)
                button.setTitleColor(
                    UIColor(red: 0.02, green: 0.19, blue: 0.38, alpha: 1.0),
                    for: .normal
                )
                button.layer.borderWidth = 1
                button.layer.borderColor =
                    UIColor(red: 0.70, green: 0.83, blue: 0.96, alpha: 1.0).cgColor
            } else {
                button.backgroundColor = .white
                button.setTitleColor(
                    UIColor(red: 0.02, green: 0.19, blue: 0.38, alpha: 1.0),
                    for: .normal
                )
                button.layer.borderWidth = 1
                button.layer.borderColor =
                    UIColor(red: 0.80, green: 0.86, blue: 0.93, alpha: 1.0).cgColor
            }
        }
    }
}
