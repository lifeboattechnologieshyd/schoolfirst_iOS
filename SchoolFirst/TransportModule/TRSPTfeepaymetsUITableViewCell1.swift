//
//  TRSPTfeepaymetsUITableViewCell1.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 29/07/26.
//

import UIKit

class TRSPTfeepaymetsUITableViewCell1: UITableViewCell {

    @IBOutlet weak var Accountnumberheadinglabel: UILabel!
    @IBOutlet weak var outstandingheadingLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBOutlet weak var LastpaidheadingLabel: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    private func setupFonts() {
       
       
        Accountnumberheadinglabel?.font = .hankenSemiBold(size: 14)
        
        outstandingheadingLabel?.font = .hankenSemiBold(size: 12)
       
        LastpaidheadingLabel?.font = .hankenSemiBold(size: 12)
    }
    
}
