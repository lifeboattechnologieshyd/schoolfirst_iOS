//
//  CurriculumLessonCell.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 24/10/25.
//

import UIKit

class CurriculumLessonCell: UITableViewCell {

    @IBOutlet weak var lblNumber: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var bgView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bgView.applyCardShadow()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
