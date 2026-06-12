//
//  ModulesCollectionViewCell.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 21/05/26.
//

import UIKit

class ModulesCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var ModuleTitle: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        // Border
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor

        // Corner Radius
        view.layer.cornerRadius = 12

        // Shadow
        view.layer.shadowColor = UIColor.lightGray.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 2
        view.layer.masksToBounds = false
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        view.layer.shadowPath = UIBezierPath(
            roundedRect: view.bounds,
            cornerRadius: 12
        ).cgPath
    }
}
