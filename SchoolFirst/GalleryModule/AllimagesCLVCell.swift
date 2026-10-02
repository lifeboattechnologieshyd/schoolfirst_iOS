//
//  AllimagesCLVCell.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 30/09/26.
//

import UIKit

class AllimagesCLVCell: UICollectionViewCell {

    @IBOutlet weak var DateLabel: UILabel!
    @IBOutlet weak var EventnameLabel: UILabel!
    @IBOutlet weak var Backgroundview: UIView!
    @IBOutlet weak var EventtypeLabel: UILabel!
    @IBOutlet weak var Imageview: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    private func setupUI() {
        // Card
        Backgroundview.backgroundColor = .white
        Backgroundview.layer.cornerRadius = 16
        Backgroundview.layer.masksToBounds = true

        // Soft shadow (Figma style)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 10
        layer.masksToBounds = false
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        // Image
        Imageview.contentMode = .scaleAspectFill
        Imageview.clipsToBounds = true
        Imageview.layer.cornerRadius = 12
        Imageview.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner] // only top corners

        // Title
        EventnameLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        EventnameLabel.textColor = UIColor(red: 0.11, green: 0.16, blue: 0.25, alpha: 1) // dark navy
        EventnameLabel.numberOfLines = 2

        // Meta (photos + date)
        DateLabel.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        DateLabel.textColor = UIColor(red: 0.45, green: 0.53, blue: 0.60, alpha: 1)

        // Category chip (Academic / Events …)
        EventtypeLabel.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        EventtypeLabel.textColor = UIColor(red: 0.05, green: 0.35, blue: 0.60, alpha: 1)
        EventtypeLabel.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        EventtypeLabel.layer.cornerRadius = 8
        EventtypeLabel.clipsToBounds = true
        EventtypeLabel.textAlignment = .center
    }

    func configure(title: String, eventType: String, dateText: String, imageName: String) {
        EventnameLabel.text = title
        DateLabel.text = dateText
        EventtypeLabel.text = "  \(eventType)  "

        // Replace with real image loading later (Kingfisher / SDWebImage etc.)
        if let img = UIImage(named: imageName) {
            Imageview.image = img
        } else {
            Imageview.backgroundColor = UIColor(white: 0.9, alpha: 1)
            Imageview.image = UIImage(systemName: "photo")
            Imageview.tintColor = .gray
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // keep shadow path updated
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 16).cgPath
    }
}
