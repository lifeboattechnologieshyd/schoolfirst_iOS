//
//  EventnameCLVcell.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 30/09/26.
//

import UIKit

class EventnameCLVcell: UICollectionViewCell {

    @IBOutlet weak var EventnameLabel: UILabel!

    private let selectedBlue = UIColor(red: 0/255, green: 92/255, blue: 170/255, alpha: 1)
    private let unselectedText = UIColor(red: 100/255, green: 116/255, blue: 139/255, alpha: 1) // #64748B

    override func awakeFromNib() {
        super.awakeFromNib()
        setupStyle()
    }

    private func setupStyle() {
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = 1.5

        EventnameLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        EventnameLabel.textAlignment = .center
        EventnameLabel.numberOfLines = 1
    }

    // MARK: - Selection Style
    func configure(title: String, isSelected: Bool) {
        EventnameLabel.text = title

        if isSelected {
            // ✅ Selected → Blue background + White text
            contentView.backgroundColor = selectedBlue
            contentView.layer.borderColor = selectedBlue.cgColor
            EventnameLabel.textColor = .white
        } else {
            // Unselected → White background + Blue border + Gray text
            contentView.backgroundColor = .white
            contentView.layer.borderColor = UIColor(red: 0/255, green: 92/255, blue: 170/255, alpha: 0.35).cgColor
            EventnameLabel.textColor = unselectedText
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        EventnameLabel.text = nil
    }
}
