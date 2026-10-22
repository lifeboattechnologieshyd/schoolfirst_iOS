//
//  LeaverequestsTBLVCLL1.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 21/10/26.
//

import UIKit

class LeaverequestsTBLVCLL1: UITableViewCell {

    @IBOutlet weak var Cantainerview2: UIView!
    @IBOutlet weak var Cantainerview: UIView!
    
    // MARK: - Properties for Filter Buttons
    private let filterScrollView = UIScrollView()
    private let filterStackView = UIStackView()
    private var filterButtons: [UIButton] = []
    private var selectedFilter: String = "All"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        setupSummaryCards()
        setupFilterTabs()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - 1. Setup 3 Summary Cards in Cantainerview
    private func setupSummaryCards() {
        // Clear existing views just in case
        Cantainerview.subviews.forEach { $0.removeFromSuperview() }
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        Cantainerview.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: Cantainerview.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: Cantainerview.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: Cantainerview.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: Cantainerview.bottomAnchor)
        ])
        
        // Create the 3 cards
        let pendingCard = createSummaryCard(title: "Pending", count: "1", countColor: UIColor(red: 0.96, green: 0.62, blue: 0.04, alpha: 1.0)) // Orange
        let approvedCard = createSummaryCard(title: "Approved", count: "1", countColor: UIColor(red: 0.13, green: 0.70, blue: 0.38, alpha: 1.0)) // Green
        let rejectedCard = createSummaryCard(title: "Rejected", count: "1", countColor: UIColor(red: 0.92, green: 0.26, blue: 0.21, alpha: 1.0)) // Red
        
        stackView.addArrangedSubview(pendingCard)
        stackView.addArrangedSubview(approvedCard)
        stackView.addArrangedSubview(rejectedCard)
    }
    
    private func createSummaryCard(title: String, count: String, countColor: UIColor) -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 8
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor(red: 0.90, green: 0.91, blue: 0.93, alpha: 1.0).cgColor
        card.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = UIColor(red: 0.42, green: 0.45, blue: 0.50, alpha: 1.0)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let countLabel = UILabel()
        countLabel.text = count
        countLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        countLabel.textColor = countColor
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(titleLabel)
        card.addSubview(countLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            
            countLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            countLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            countLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -10)
        ])
        
        return card
    }
    
    // MARK: - 2. Setup Filter Tabs in Cantainerview2
    private func setupFilterTabs() {
        Cantainerview2.subviews.forEach { $0.removeFromSuperview() }
        
        filterScrollView.showsHorizontalScrollIndicator = false
        filterScrollView.translatesAutoresizingMaskIntoConstraints = false
        Cantainerview2.addSubview(filterScrollView)
        
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
            
            filterStackView.topAnchor.constraint(equalTo: filterScrollView.topAnchor),
            filterStackView.leadingAnchor.constraint(equalTo: filterScrollView.leadingAnchor),
            filterStackView.trailingAnchor.constraint(equalTo: filterScrollView.trailingAnchor),
            filterStackView.bottomAnchor.constraint(equalTo: filterScrollView.bottomAnchor),
            filterStackView.heightAnchor.constraint(equalTo: filterScrollView.heightAnchor)
        ])
        
        let filterTitles = ["All", "Pending", "Approved", "Rejected"]
        
        for (index, title) in filterTitles.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .medium)
            button.layer.cornerRadius = 16
            button.tag = index
            button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)
            button.addTarget(self, action: #selector(filterTapped(_:)), for: .touchUpInside)
            
            filterButtons.append(button)
            filterStackView.addArrangedSubview(button)
        }
        
        updateFilterButtonStyles()
    }
    
    @objc private func filterTapped(_ sender: UIButton) {
        if let title = sender.title(for: .normal) {
            selectedFilter = title
            updateFilterButtonStyles()
            // You can trigger a closure here later to reload the tableview
        }
    }
    
    private func updateFilterButtonStyles() {
        for button in filterButtons {
            let isSelected = button.title(for: .normal) == selectedFilter
            
            if isSelected {
                // Selected state: Light gray background, dark text, no border
                button.backgroundColor = UIColor(red: 0.94, green: 0.96, blue: 0.99, alpha: 1.0)
                button.setTitleColor(UIColor(red: 0.07, green: 0.09, blue: 0.15, alpha: 1.0), for: .normal)
                button.layer.borderWidth = 0
            } else {
                // Unselected state: White background, gray text, gray border
                button.backgroundColor = .white
                button.setTitleColor(UIColor(red: 0.42, green: 0.45, blue: 0.50, alpha: 1.0), for: .normal)
                button.layer.borderWidth = 1
                button.layer.borderColor = UIColor(red: 0.85, green: 0.87, blue: 0.90, alpha: 1.0).cgColor
            }
        }
    }
}
