//
//  HWFooterCell.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 11/11/25.
//

import UIKit

class HWFooterCell: UITableViewCell {
    @IBOutlet weak var lblCount: UILabel!
    
    @IBOutlet weak var btnComplete: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
