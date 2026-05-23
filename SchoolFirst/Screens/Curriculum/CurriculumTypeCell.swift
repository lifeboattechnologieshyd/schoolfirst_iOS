//
//  CurriculumTypeCell.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 20/10/25.
//

import UIKit

class CurriculumTypeCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
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
