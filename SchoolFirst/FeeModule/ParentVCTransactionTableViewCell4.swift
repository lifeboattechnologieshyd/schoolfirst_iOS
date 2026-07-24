//
//  ParentVCTransactionTableViewCell4.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 21/07/26.
//

import UIKit

class ParentVCTransactionTableViewCell4: UITableViewCell {

    @IBOutlet weak var PaymentStatusLbl: UILabel!
   
    @IBOutlet weak var Paidamount: UILabel!
    @IBOutlet weak var TransactionIDLbl: NSLayoutConstraint!
   
    
    @IBOutlet weak var PaymentDatetimeLbl: UILabel!
   
    // MARK: - Callbacks

   

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()

       
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
    }

    override func setSelected(
        _ selected: Bool,
        animated: Bool
    ) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: - Button Actions

   

   
}
