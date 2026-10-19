//
//  leaveapplyTableViewCell.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 19/10/26.
//

import UIKit

class leaveapplyTableViewCell: UITableViewCell {

    @IBOutlet weak var Reasonscantainerview: UIView!
    
    // MARK: - Reason UI Properties
    private let reasonTitleLabel = UILabel()
    private let reasonStackView = UIStackView()
    private var reasonButtons: [UIButton] = []
    private var selectedReason: String = "Medical" // Default selection
    
    // Colors from Figma
    private let selectedColor = UIColor(red: 0.25, green: 0.47, blue: 0.95, alpha: 1.0) // App Primary Blue
    private let unselectedTextColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
    
    // ✅ FIXED: Renamed from 'borderColor' to avoid UIKit conflict
    private let unselectedBorderColor = UIColor(red: 0.85, green: 0.87, blue: 0.90, alpha: 1.0).cgColor
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        setupReasonSection()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Setup Reason Section (Figma)
    private func setupReasonSection() {
        // Clean up any existing views just in case
        Reasonscantainerview.subviews.forEach { $0.removeFromSuperview() }
        
        // 1. "Reason" Title Label
        reasonTitleLabel.text = "Reason"
        reasonTitleLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        reasonTitleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        reasonTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 2. Horizontal Stack View for Buttons
        reasonStackView.axis = .horizontal
        reasonStackView.spacing = 8
        reasonStackView.distribution = .fillProportionally // Adjusts width based on text
        reasonStackView.alignment = .fill
        reasonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // 3. Create Buttons
        let reasons = ["Medical", "Family", "Religious", "Other"]
        
        for (index, reason) in reasons.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(reason, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .medium)
            button.layer.cornerRadius = 8
            button.tag = index
            button.addTarget(self, action: #selector(reasonButtonTapped(_:)), for: .touchUpInside)
            
            // Height constraint for buttons (Figma shows ~36px)
            button.heightAnchor.constraint(equalToConstant: 36).isActive = true
            
            reasonButtons.append(button)
            reasonStackView.addArrangedSubview(button)
        }
        
        // Add to container
        Reasonscantainerview.addSubview(reasonTitleLabel)
        Reasonscantainerview.addSubview(reasonStackView)
        
        // 4. Layout Constraints inside Reasonscantainerview
        NSLayoutConstraint.activate([
            reasonTitleLabel.topAnchor.constraint(equalTo: Reasonscantainerview.topAnchor, constant: 0),
            reasonTitleLabel.leadingAnchor.constraint(equalTo: Reasonscantainerview.leadingAnchor, constant: 0),
            reasonTitleLabel.trailingAnchor.constraint(equalTo: Reasonscantainerview.trailingAnchor, constant: 0),
            
            reasonStackView.topAnchor.constraint(equalTo: reasonTitleLabel.bottomAnchor, constant: 8),
            reasonStackView.leadingAnchor.constraint(equalTo: Reasonscantainerview.leadingAnchor, constant: 0),
            reasonStackView.trailingAnchor.constraint(equalTo: Reasonscantainerview.trailingAnchor, constant: 0),
            reasonStackView.bottomAnchor.constraint(equalTo: Reasonscantainerview.bottomAnchor, constant: 0)
        ])
        
        // Apply initial styling
        updateButtonStyles()
    }
    
    // MARK: - Button Action
    @objc private func reasonButtonTapped(_ sender: UIButton) {
        if let title = sender.title(for: .normal) {
            selectedReason = title
            updateButtonStyles()
        }
    }
    
    // MARK: - Styling
    private func updateButtonStyles() {
        for button in reasonButtons {
            if button.title(for: .normal) == selectedReason {
                // Selected State
                button.backgroundColor = selectedColor
                button.setTitleColor(.white, for: .normal)
                button.layer.borderWidth = 0
                button.layer.borderColor = UIColor.clear.cgColor
            } else {
                // Unselected State
                button.backgroundColor = .white
                button.setTitleColor(unselectedTextColor, for: .normal)
                button.layer.borderWidth = 1
                button.layer.borderColor = unselectedBorderColor // ✅ Updated to use the new name
            }
        }
    }
}
