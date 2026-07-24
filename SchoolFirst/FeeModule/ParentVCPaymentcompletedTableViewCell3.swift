//
//  ParentVCPaymentcompletedTableViewCell3.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 21/07/26.
//

import UIKit

class ParentVCPaymentcompletedTableViewCell3: UITableViewCell {

    @IBOutlet weak var PaymentstatusLbl: UILabel!
    @IBOutlet weak var PaidfeetypeLbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: - Configure with Completed Fee Item
    func configure(with feeItem: CompletedFeeItem) {
        PaidfeetypeLbl.text = feeItem.feeType
        PaymentstatusLbl.text = feeItem.displayStatus
        configureStatusColor(feeItem.status)
    }

    // MARK: - Configure Loading/Empty States
    func configureLoading() {
        PaidfeetypeLbl.text = "Loading..."
        PaymentstatusLbl.text = ""
        PaymentstatusLbl.textColor = .darkGray
    }

    func configureEmpty() {
        PaidfeetypeLbl.text = "No completed payments"
        PaymentstatusLbl.text = ""
        PaymentstatusLbl.textColor = .darkGray
    }

    // MARK: - Private Helpers
    private func configureStatusColor(_ status: String) {
        switch status.uppercased() {
        case "PAID":
            PaymentstatusLbl.textColor = UIColor(red: 34/255, green: 197/255, blue: 94/255, alpha: 1.0)
        case "PARTIAL":
            PaymentstatusLbl.textColor = UIColor(red: 255/255, green: 152/255, blue: 0/255, alpha: 1.0)
        case "PENDING":
            PaymentstatusLbl.textColor = UIColor(red: 239/255, green: 68/255, blue: 68/255, alpha: 1.0)
        default:
            PaymentstatusLbl.textColor = .darkGray
        }
    }

    private func formatValue(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        PaidfeetypeLbl.text = nil
        PaymentstatusLbl.text = nil
        PaymentstatusLbl.textColor = .darkGray
    }
}
