//
//  TRSPRdropUITableviewcell3.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 04/08/26.
//

import UIKit

class TRSPRdropUITableviewcell3: UITableViewCell {

    @IBOutlet weak var MessageButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        MessageButton.clipsToBounds = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
