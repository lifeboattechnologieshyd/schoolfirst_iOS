//
//  ParentfeeVCTableViewCell.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 23/06/26.
//

import UIKit

class ParentfeeVCTableViewCell: UITableViewCell {

    @IBOutlet weak var TermtotalpayableamountLbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        TermtotalpayableamountLbl.text = nil
    }

    func configure(totalPayableAmount: Double?) {
        guard let amount = totalPayableAmount else {
            TermtotalpayableamountLbl.text = "₹0"
            return
        }

        TermtotalpayableamountLbl.text = "₹\(formatAmount(amount))"
    }

    private func formatAmount(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
