//
//  HWSubjectWiseCell.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 11/11/25.
//

import UIKit

class HWSubjectWiseCell: UITableViewCell {
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
