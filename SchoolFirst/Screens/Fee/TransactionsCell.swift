//
//  TransactionsCell.swift
//  SchoolFirst
//
//  Created by Lifeboat on 14/11/25.
//

import UIKit

class TransactionsCell: UITableViewCell {
    
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var amountLbl: UILabel!
    @IBOutlet weak var referencenoLbl: UILabel!
    @IBOutlet weak var marVw: UIView!
    @IBOutlet weak var paymentMethodLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
         marVw.addCardShadow()

        
    }
}
