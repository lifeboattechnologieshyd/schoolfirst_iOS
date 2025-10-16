//
//  HomeViewCell.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 03/09/25.
//

import UIKit

class HomeViewCell: UICollectionViewCell {
    
    @IBOutlet weak var bgVw: UIView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgVw: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        contentView.clipsToBounds = false
        clipsToBounds = false
        bgVw.homeScreenCardLook()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
    }

    func config(name: String, imageName: String) {
        self.lblName.text = name
        self.imgVw.image = UIImage(named: imageName)
    }
    
}
