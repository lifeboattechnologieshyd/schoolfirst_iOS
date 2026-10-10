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
        // Uses totalAmount for both labels
        let displayAmount = totalAmount ?? totalPayableAmount ?? 0.0
        let formattedText = "₹\(formatAmount(displayAmount))"

        TermtotalpayableamountLbl.text = formattedText
        TotalamountLbl.text = formattedText
    }

    private func formatAmount(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "en_IN")
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? String(format: "%.0f", value)
    }
}
