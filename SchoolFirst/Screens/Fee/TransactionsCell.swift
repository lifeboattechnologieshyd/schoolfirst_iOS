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
        selectionStyle = .none
    }
    
    func configure(with transaction: FeeTransaction) {
        // Reference ID
        referencenoLbl.text = transaction.referenceId
        
        // Transaction Date & Time
        let date = Date(timeIntervalSince1970: transaction.transactionTime / 1000)
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy, hh:mm a"
        dateLbl.text = formatter.string(from: date)
        
        // Payment Mode
        paymentMethodLbl.text = transaction.paymentMode.capitalized
        
        // Amount with color based on transaction type
        let isCredit = transaction.transactionType.uppercased() == "CREDIT"
        
        if isCredit {
            amountLbl.text = "+ ₹\(Int(transaction.amount))"
            amountLbl.textColor = UIColor(red: 0.0, green: 0.6, blue: 0.0, alpha: 1.0) // Green
        } else {
            amountLbl.text = "- ₹\(Int(transaction.amount))"
            amountLbl.textColor = UIColor(red: 0.8, green: 0.0, blue: 0.0, alpha: 1.0) // Red
        }
    }
}
