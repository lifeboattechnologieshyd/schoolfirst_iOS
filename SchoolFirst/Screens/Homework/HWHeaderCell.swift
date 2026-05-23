//
//  HWHeaderCell.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 10/11/25.
//

import UIKit

class HWHeaderCell: UITableViewCell {
    @IBOutlet weak var lbldate: UILabel!
    
    @IBOutlet weak var lbldeadline: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
