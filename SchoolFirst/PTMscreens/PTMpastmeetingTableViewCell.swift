//
//  PTMpastmeetingTableViewCell.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 18/07/26.
//

import UIKit

class PTMpastmeetingTableViewCell: UITableViewCell {

    @IBOutlet weak var StudentnameLbl: UILabel!
    @IBOutlet weak var MeetingmonthLbl: UILabel!
    @IBOutlet weak var MeetingtimeLbl: UILabel!
    @IBOutlet weak var StaffnameLbl: UILabel!
    @IBOutlet weak var StudentgradeLbl: UILabel!
    @IBOutlet weak var MeetingtitleLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
