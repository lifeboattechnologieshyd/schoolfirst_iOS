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
        
        
    }
    func setup(student: Student, isSelected: Bool) {
        lblNAme.text = student.name
        lblGrade.text = student.grade ?? "Grade not set"
        
        if let imageUrl = student.image, !imageUrl.isEmpty {
            imgVw.loadImage(url: imageUrl)
        } else {
            imgVw.image = UIImage(named: "Profile")
        }
        
           
        if isSelected {
            bgView.layer.borderColor = UIColor.primary.cgColor
        } else {
            bgView.layer.borderColor = UIColor(red: 0.8, green: 0.9, blue: 0.99, alpha: 1.0).cgColor
        }
    }
}
