//
//  KidSelectionCell.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 20/10/25.
//

import UIKit

class KidSelectionCell: UICollectionViewCell {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var imgVw: UIImageView!
    @IBOutlet weak var lblNAme: UILabel!
    @IBOutlet weak var lblGrade: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Hide grade label
        lblGrade.isHidden = true
        
        // Image view with border
        imgVw.clipsToBounds = true
        imgVw.contentMode = .scaleAspectFill
        imgVw.layer.borderWidth = 1.5
        imgVw.layer.borderColor = UIColor.primary.cgColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Keep image circular with border
        imgVw.layer.cornerRadius = imgVw.bounds.height / 2
    }
    
    func setup(student: Student, isSelected: Bool) {
        lblNAme.text = student.name
        
        // Grade is not shown
        lblGrade.text = nil
        lblGrade.isHidden = true
        
        if let imageUrl = student.image, !imageUrl.isEmpty {
            imgVw.loadImage(url: imageUrl)
        } else {
            imgVw.image = UIImage(named: "Profile")
        }
        
        if isSelected {
            bgView.layer.borderColor = UIColor.primary.cgColor
            imgVw.layer.borderColor = UIColor.primary.cgColor
        } else {
            bgView.layer.borderColor = UIColor(red: 0.8, green: 0.9, blue: 0.99, alpha: 1.0).cgColor
            imgVw.layer.borderColor = UIColor(red: 0.8, green: 0.9, blue: 0.99, alpha: 1.0).cgColor
        }
    }
}
