//
//  ContactdashboardTBLVCLL.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 18/09/26.
//

import UIKit

class ContactdashboardTBLVCLL: UITableViewCell {

    @IBOutlet weak var containerview: UIView!
    
    // MARK: - Data Model
    private struct ContactOption {
        let title: String
        let subtitle: String
        let iconName: String
        let iconColor: UIColor
        let iconBgColor: UIColor
    }
    
    private let contactOptions: [ContactOption] = [
        ContactOption(title: "Teacher's", subtitle: "Connect with your child's", iconName: "person", iconColor: .systemBlue, iconBgColor: UIColor.systemBlue.withAlphaComponent(0.1)),
        ContactOption(title: "Administration", subtitle: "General enquiries & support", iconName: "building.2", iconColor: .systemPurple, iconBgColor: UIColor.systemPurple.withAlphaComponent(0.1)),
        ContactOption(title: "Principal", subtitle: "School leadership contact", iconName: "graduationcap", iconColor: .systemOrange, iconBgColor: UIColor.systemOrange.withAlphaComponent(0.15)),
        ContactOption(title: "Accounts", subtitle: "Fee payments & receipts", iconName: "creditcard", iconColor: .systemGreen, iconBgColor: UIColor.systemGreen.withAlphaComponent(0.1)),
        ContactOption(title: "Transport", subtitle: "Bus routes & schedules", iconName: "bus", iconColor: .systemTeal, iconBgColor: UIColor.systemTeal.withAlphaComponent(0.1)),
        ContactOption(title: "Technical Support", subtitle: "App & IT help desk", iconName: "wrench.and.screwdriver", iconColor: .systemGray, iconBgColor: UIColor.systemGray.withAlphaComponent(0.15))
    ]

    override func awakeFromNib() {
        super.awakeFromNib()
        setupGrid()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Grid Setup
    private func setupGrid() {
        // Clear container in case of cell reuse
        containerview.subviews.forEach { $0.removeFromSuperview() }
        containerview.backgroundColor = .clear
        
        // Main Vertical Stack (Rows)
        let mainVStack = UIStackView()
        mainVStack.axis = .vertical
        mainVStack.spacing = 12
        mainVStack.distribution = .fillEqually
        mainVStack.translatesAutoresizingMaskIntoConstraints = false
        
        containerview.addSubview(mainVStack)
        
        // Pin mainVStack to containerview edges
        NSLayoutConstraint.activate([
            mainVStack.topAnchor.constraint(equalTo: containerview.topAnchor),
            mainVStack.leadingAnchor.constraint(equalTo: containerview.leadingAnchor),
            mainVStack.trailingAnchor.constraint(equalTo: containerview.trailingAnchor),
            mainVStack.bottomAnchor.constraint(equalTo: containerview.bottomAnchor)
        ])
        
        // Group data into pairs for rows (2 items per row)
        for i in stride(from: 0, to: contactOptions.count, by: 2) {
            let rowHStack = UIStackView()
            rowHStack.axis = .horizontal
            rowHStack.spacing = 12
            rowHStack.distribution = .fillEqually
            
            // Item 1 (Left Column)
            let card1 = createCardView(for: contactOptions[i])
            rowHStack.addArrangedSubview(card1)
            
            // Item 2 (Right Column) - Safely check if it exists
            if i + 1 < contactOptions.count {
                let card2 = createCardView(for: contactOptions[i + 1])
                rowHStack.addArrangedSubview(card2)
            } else {
                // Empty view to maintain grid structure if odd number of items
                let emptyView = UIView()
                emptyView.backgroundColor = .clear
                rowHStack.addArrangedSubview(emptyView)
            }
            
            mainVStack.addArrangedSubview(rowHStack)
        }
    }
    
    // MARK: - Individual Card Builder
    private func createCardView(for data: ContactOption) -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 16
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.systemGray5.cgColor
        card.translatesAutoresizingMaskIntoConstraints = false
        
        // Strict Height Constraint (116 as requested)
        card.heightAnchor.constraint(equalToConstant: 116).isActive = true
        
        // Icon Background Container
        let iconBg = UIView()
        iconBg.backgroundColor = data.iconBgColor
        iconBg.layer.cornerRadius = 8
        iconBg.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(iconBg)
        
        // Icon Image
        let iconImg = UIImageView()
        iconImg.image = UIImage(systemName: data.iconName)
        iconImg.tintColor = data.iconColor
        iconImg.contentMode = .scaleAspectFit
        iconImg.translatesAutoresizingMaskIntoConstraints = false
        iconBg.addSubview(iconImg)
        
        // Chevron Icon (Top Right)
        let chevron = UIImageView()
        let config = UIImage.SymbolConfiguration(weight: .semibold)
        chevron.image = UIImage(systemName: "chevron.right", withConfiguration: config)
        chevron.tintColor = .systemGray4
        chevron.contentMode = .scaleAspectFit
        chevron.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(chevron)
        
        // Title Label
        let titleLabel = UILabel()
        titleLabel.text = data.title
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        titleLabel.textColor = .darkText
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(titleLabel)
        
        // Subtitle Label
        let subtitleLabel = UILabel()
        subtitleLabel.text = data.subtitle
        subtitleLabel.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        subtitleLabel.textColor = .gray
        subtitleLabel.numberOfLines = 2
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(subtitleLabel)
        
        // Constraints
        NSLayoutConstraint.activate([
            // Icon Background: Top-Left
            iconBg.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            iconBg.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            iconBg.widthAnchor.constraint(equalToConstant: 34),
            iconBg.heightAnchor.constraint(equalToConstant: 34),
            
            // Icon inside Background
            iconImg.centerXAnchor.constraint(equalTo: iconBg.centerXAnchor),
            iconImg.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor),
            iconImg.widthAnchor.constraint(equalToConstant: 18),
            iconImg.heightAnchor.constraint(equalToConstant: 18),
            
            // Chevron: Top-Right
            chevron.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            chevron.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            chevron.widthAnchor.constraint(equalToConstant: 12),
            chevron.heightAnchor.constraint(equalToConstant: 12),
            
            // Title: Below Icon
            titleLabel.topAnchor.constraint(equalTo: iconBg.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            
            // Subtitle: Below Title
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            subtitleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14)
        ])
        
        return card
    }
}
