//
//  InvoiceTableViewCell.swift
//  SchoolFirst
//
//  Created by Lifeboat on 24/10/25.
//

import UIKit




class InvoiceTableViewCell: UITableViewCell {

     

    @IBOutlet weak var discountamtLbl: UILabel!
    @IBOutlet weak var mrpamtLbl: UILabel!
    @IBOutlet weak var finalamountLbl: UILabel!
    @IBOutlet weak var mrpLbl: UILabel!
    @IBOutlet weak var invoiceVw: UIView!
    @IBOutlet weak var discountLbl: UILabel!
    @IBOutlet weak var gstLbl: UILabel!
    @IBOutlet weak var exclusiveGstamtLbl: UILabel!
    @IBOutlet weak var gstamtLbl: UILabel!
    @IBOutlet weak var finalpriceLbl: UILabel!
    @IBOutlet weak var invoiceLbl: UILabel!
    @IBOutlet weak var freeLbl: UILabel!
    @IBOutlet weak var excGstLbl: UILabel!
    @IBOutlet weak var totalamountLbl: UILabel!
    @IBOutlet weak var shippingLbl: UILabel!
    @IBOutlet weak var totalPayableLbl: UILabel!
    @IBOutlet weak var invoiceImg: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        

        // Add separator lines
        addSeparatorLine(below: discountLbl, color: UIColor(hex: "#CDE1D7")!)
        addSeparatorLine(below: shippingLbl, color: UIColor(hex: "#CDE1D7")!)
        addSeparatorLine(below: totalamountLbl, color: UIColor(hex: "#CDE1D7")!)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func addSeparatorLine(below view: UIView, color: UIColor, height: CGFloat = 1) {
        let line = UIView()
        line.backgroundColor = color
        line.translatesAutoresizingMaskIntoConstraints = false
        invoiceVw.addSubview(line)
        
        NSLayoutConstraint.activate([
            line.topAnchor.constraint(equalTo: view.bottomAnchor, constant: 4), // space below the label
            line.leadingAnchor.constraint(equalTo: invoiceVw.leadingAnchor, constant: 0),
            line.trailingAnchor.constraint(equalTo: invoiceVw.trailingAnchor, constant: 0),
            line.heightAnchor.constraint(equalToConstant: height)
        ])
    }
}
