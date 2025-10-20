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
    
    func setup(student: Student, isSelected : Bool){
        lblNAme.text = "For \(student.name)"
        lblGrade.text = student.grade
        imgVw.loadImage(url: student.image ?? "")
        bgView.layer.borderColor = isSelected ? UIColor.primary.cgColor : UIColor(hex: "#CBE5FD")?.cgColor
    }
}
