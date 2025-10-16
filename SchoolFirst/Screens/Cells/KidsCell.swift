//
//  KidsCell.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 21/08/25.
//

import UIKit

class KidsCell: UITableViewCell {
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblGrade: UILabel!
    @IBOutlet weak var imgVw: UIImageView!
    
    @IBOutlet weak var bgView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.applyCardShadow()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setupCell(student : Student) {
        self.imgVw.loadImage(url: student.image ?? "", placeHolderImage: "dummy_profile_pic")
        self.lblName.text = student.name
        self.lblGrade.text = student.grade
    }
    
}
