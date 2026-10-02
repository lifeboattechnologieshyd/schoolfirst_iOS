//
//  SingleeventCLVcell.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 30/09/26.
//

import UIKit

class SingleeventCLVcell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var badgeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var metaLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        // Card – radius 16, white, light border (Figma)
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 16
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor(red: 0.89, green: 0.91, blue: 0.94, alpha: 1).cgColor // #E2E8F0
        containerView.clipsToBounds = true

        // Soft shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.07
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 10
        layer.masksToBounds = false

        // Image
        eventImageView.contentMode = .scaleAspectFill
        eventImageView.clipsToBounds = true
        eventImageView.backgroundColor = UIColor(white: 0.93, alpha: 1)

        // Badge (top-right on image)
        badgeLabel.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        badgeLabel.textColor = UIColor(red: 0.05, green: 0.35, blue: 0.60, alpha: 1)
        badgeLabel.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        badgeLabel.layer.cornerRadius = 8
        badgeLabel.clipsToBounds = true
        badgeLabel.textAlignment = .center

        // Title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = UIColor(red: 0.09, green: 0.14, blue: 0.22, alpha: 1)
        titleLabel.numberOfLines = 1

        // Subtitle
        subtitleLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.textColor = UIColor(red: 0.40, green: 0.48, blue: 0.55, alpha: 1)
        subtitleLabel.numberOfLines = 2

        // Meta
        metaLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        metaLabel.textColor = UIColor(red: 0.45, green: 0.53, blue: 0.60, alpha: 1)
    }

    func configure(title: String, subtitle: String, meta: String, badge: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        metaLabel.text = meta
        badgeLabel.text = "  \(badge)  "

        // Placeholder until you set real images
        eventImageView.image = UIImage(systemName: "image cover")
        eventImageView.tintColor = .lightGray
        eventImageView.contentMode = .scaleAspectFit
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 16).cgPath
    }
}
