//
//  ParentfeeVCTableViewCell.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 23/06/26.
//

import UIKit

class ParentfeeVCTableViewCell: UITableViewCell {

    @IBOutlet weak var TotalamountLbl: UILabel!
    @IBOutlet weak var TermtotalpayableamountLbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        TermtotalpayableamountLbl.text = nil
        TotalamountLbl.text = nil
    }

    func configure(totalPayableAmount: Double?, totalAmount: Double?) {
        guard let payable = totalPayableAmount else {
            TermtotalpayableamountLbl.text = "₹0"
            TotalamountLbl.text = "₹0"
            return
        }

        TermtotalpayableamountLbl.text = "₹\(formatAmount(payable))"
        
        if let total = totalAmount {
            TotalamountLbl.text = "₹\(formatAmount(total))"
        } else {
            TotalamountLbl.text = "₹\(formatAmount(payable))"
        }
    }

    private func formatAmount(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
