//
//  CalendarBannerCell.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 03/09/25.
//

import UIKit

class CalendarBannerCell: UITableViewCell {
    @IBOutlet weak var lblMonth: UILabel!
    
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblPrompt: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
   
}
