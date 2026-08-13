//
//  ParentVCTransactionTableViewCell4.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 21/07/26.
//

import UIKit

class ParentVCTransactionTableViewCell4: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var PaymentStatusLbl:   UILabel!
    @IBOutlet weak var Paidamount:         UILabel!
      // ✅ FIXED: was NSLayoutConstraint — reconnect in XIB!
    @IBOutlet weak var TransactionIDLbl: UILabel!
    @IBOutlet weak var PaymentDatetimeLbl: UILabel!

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        verifyOutlets()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        PaymentStatusLbl?.text   = nil
        Paidamount?.text         = nil
        TransactionIDLbl?.text   = nil
        PaymentDatetimeLbl?.text = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: - Verify Outlets (debug helper)
    private func verifyOutlets() {
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("🔍 ParentVCTransactionTableViewCell4 — verifyOutlets()")
        print("   PaymentStatusLbl   :", PaymentStatusLbl   == nil ? "❌ NOT CONNECTED" : "✅ connected")
        print("   Paidamount         :", Paidamount         == nil ? "❌ NOT CONNECTED" : "✅ connected")
        print("   TransactionIDLbl   :", TransactionIDLbl   == nil ? "❌ NOT CONNECTED" : "✅ connected")
        print("   PaymentDatetimeLbl :", PaymentDatetimeLbl == nil ? "❌ NOT CONNECTED" : "✅ connected")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    }

    // MARK: - Configure with Last Transaction
    // Called with the most recent CompletedFeeTransaction
    func configure(with transaction: CompletedFeeTransaction) {

        // Paid Amount → "₹3,000"
        Paidamount?.text = transaction.formattedTotalAmount

        // Transaction Reference Number → "TXN-9108037C6CD1"
        TransactionIDLbl?.text = transaction.referenceNumber

        // Payment Date → "22 Jul 2026"
        PaymentDatetimeLbl?.text = transaction.formattedPaymentDate

        // Status → from first fee item in this transaction ("Paid" / "Partial")
        if let firstFee = transaction.fees.first {
            PaymentStatusLbl?.text = firstFee.displayStatus
            configureStatusColor(firstFee.status)
        } else {
            PaymentStatusLbl?.text      = "Paid"
            PaymentStatusLbl?.textColor = UIColor(red: 34/255, green: 197/255, blue: 94/255, alpha: 1.0)
        }

        print("🔧 Cell4 configured → \(transaction.referenceNumber) | \(transaction.formattedTotalAmount) | \(transaction.formattedPaymentDate)")
    }

    // MARK: - Loading State
    func configureLoading() {
        PaymentStatusLbl?.text      = "──"
        Paidamount?.text            = "──"
        TransactionIDLbl?.text      = "Loading..."
        PaymentDatetimeLbl?.text    = "──"
        PaymentStatusLbl?.textColor = .darkGray
    }

    // MARK: - Status Color
    private func configureStatusColor(_ status: String) {
        switch status.uppercased() {
        case "PAID":
            PaymentStatusLbl?.textColor = UIColor(
                red: 34/255, green: 197/255, blue: 94/255, alpha: 1.0
            ) // Green
        case "PARTIAL":
            PaymentStatusLbl?.textColor = UIColor(
                red: 234/255, green: 179/255, blue: 8/255, alpha: 1.0
            ) // Yellow
        case "PENDING":
            PaymentStatusLbl?.textColor = UIColor(
                red: 239/255, green: 68/255, blue: 68/255, alpha: 1.0
            ) // Red
        default:
            PaymentStatusLbl?.textColor = .darkGray
        }
    }
}
