//
//  TransactionsCell.swift
//  SchoolFirst
//
//  Created by Lifeboat on 14/11/25.
//

import UIKit

class TransactionsCell: UITableViewCell {
    
    @IBOutlet weak var julVw: UIView!
    @IBOutlet weak var decVw: UIView!
    @IBOutlet weak var febVw: UIView!
    @IBOutlet weak var marVw: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        julVw.addCardShadow()
        decVw.addCardShadow()
        febVw.addCardShadow()
        marVw.addCardShadow()

        
    }
}
