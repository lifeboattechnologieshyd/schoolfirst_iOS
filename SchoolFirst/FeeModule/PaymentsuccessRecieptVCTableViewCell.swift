//
//  PaymentsuccessRecieptVCTableViewCell.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 24/06/26.
//

import UIKit

class PaymentsuccessRecieptVCTableViewCell: UITableViewCell {

    @IBOutlet weak var Paidamount: UILabel!
    
    @IBOutlet weak var StudentnameLbl: UILabel!
    @IBOutlet weak var PaymentDatetimeLbl: UILabel!
    @IBOutlet weak var TransactionIDLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
