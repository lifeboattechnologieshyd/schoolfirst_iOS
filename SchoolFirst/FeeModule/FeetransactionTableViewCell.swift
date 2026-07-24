//
//  FeetransactionTableViewCell.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 24/06/26.
//

import UIKit

class FeetransactionTableViewCell: UITableViewCell {

    @IBOutlet weak var StatusLbl:            UILabel!
    @IBOutlet weak var FeetypeLbl:           UILabel!
    @IBOutlet weak var RecieptdownloadButton: UIButton!
    @IBOutlet weak var PaymentDatetimeLbl:   UILabel!
    @IBOutlet weak var TransactionIDLbl:     UILabel!
    @IBOutlet weak var InstallmentLbl:       UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: - Reuse Reset
    override func prepareForReuse() {
        super.prepareForReuse()
        StatusLbl.text          = nil
        FeetypeLbl.text         = nil
        PaymentDatetimeLbl.text = nil
        TransactionIDLbl.text   = nil
        InstallmentLbl.text     = nil
    }

    // MARK: - Configure
    // Called with one CompletedFeeItem + its parent transaction info
    func configure(
        feeItem:     CompletedFeeItem,
        transaction: CompletedFeeTransaction
    ) {
        // Fee Type → "Exam Fee"
        FeetypeLbl.text = feeItem.feeType

        // Installment → "Term 1"
        InstallmentLbl.text = feeItem.installment

        // Transaction Reference Number → "TXN-9108037C6CD1"
        TransactionIDLbl.text = transaction.referenceNumber

        // Payment Date → "22 Jul 2026"
        PaymentDatetimeLbl.text = transaction.formattedPaymentDate

        // Status → "Paid" / "Partial"
        StatusLbl.text = feeItem.displayStatus

        // Status label color
        configureStatusColor(feeItem.status)

        print("🔧 Cell configured → \(feeItem.feeType) | \(feeItem.formattedPaidAmount) | \(feeItem.displayStatus)")
    }

    // MARK: - Status Color
    private func configureStatusColor(_ status: String) {
        switch status.uppercased() {
        case "PAID":
            StatusLbl.textColor = UIColor(
                red: 34/255,
                green: 197/255,
                blue: 94/255,
                alpha: 1.0
            ) // Green
        case "PARTIAL":
            StatusLbl.textColor = UIColor(
                red: 234/255,
                green: 179/255,
                blue: 8/255,
                alpha: 1.0
            ) // Yellow
        case "PENDING":
            StatusLbl.textColor = UIColor(
                red: 239/255,
                green: 68/255,
                blue: 68/255,
                alpha: 1.0
            ) // Red
        default:
            StatusLbl.textColor = .darkGray
        }
    }
}
