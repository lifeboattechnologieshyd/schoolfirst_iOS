//
//  LeaverejectTBLVCLL.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 21/10/26.
//

import UIKit

class LeaverejectTBLVCLL: UITableViewCell {

    @IBOutlet weak var BacktoleaverequestButton: UIButton!
    @IBOutlet weak var ClassandsectionandrollLabel: UILabel!
    @IBOutlet weak var DocumentattacherornotLabel: UILabel!
    @IBOutlet weak var RequestdaysLabel: UILabel!
    @IBOutlet weak var ReasonLabel: UILabel!
    @IBOutlet weak var RejecteddateLabel: UILabel!
    @IBOutlet weak var RejectreasonwithdateLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
