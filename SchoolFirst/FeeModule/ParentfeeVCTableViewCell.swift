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
        // Outstanding amount from fee_summary.outstanding_amount
        TermtotalpayableamountLbl.text =
            "₹\(formatAmount(totalPayableAmount ?? 0.0))"

        // Total fee from fee_summary.total_fee
        TotalamountLbl.text =
            "₹\(formatAmount(totalAmount ?? 0.0))"
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
