//
//  PaymentsuccessRecieptVCTableViewCell.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 24/06/26.
//

import UIKit

class PaymentsuccessRecieptVCTableViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var Paidamount: UILabel!
    @IBOutlet weak var StudentnameLbl: UILabel!
    @IBOutlet weak var PaymentDatetimeLbl: UILabel!
    @IBOutlet weak var TransactionIDLbl: UILabel!

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle  = .none
        backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        Paidamount?.text         = nil
        StudentnameLbl?.text     = nil
        PaymentDatetimeLbl?.text = nil
        TransactionIDLbl?.text   = nil
    }

    // MARK: - ✅ Configure with API Data
    /// Populates the receipt from the matched completed-payment transaction
    func configure(student: CompletedFeeStudent?,
                   transaction: CompletedFeeTransaction?) {

        // ── Student Name ─────────────────────────────────────────
        if let name = student?.name, !name.isEmpty {
            StudentnameLbl?.text = name
        } else {
            StudentnameLbl?.text = "--"
        }

        // ── Transaction Details ──────────────────────────────────
        guard let transaction = transaction else {
            Paidamount?.text         = "₹0"
            PaymentDatetimeLbl?.text = "--"
            TransactionIDLbl?.text   = "--"
            return
        }

        Paidamount?.text         = transaction.formattedTotalAmount
        PaymentDatetimeLbl?.text = transaction.formattedPaymentDateTime
        TransactionIDLbl?.text   = transaction.referenceNumber

        print("""
        🧾 RECEIPT RENDERED
           Student : \(student?.name ?? "--")
           Amount  : \(transaction.formattedTotalAmount)
           Date    : \(transaction.formattedPaymentDateTime)
           Txn ID  : \(transaction.displayTransactionId)
           Fees    : \(transaction.feeTypesJoined)
        """)
    }

    // MARK: - ⏳ Loading State
    func configureLoading() {
        Paidamount?.text         = "..."
        StudentnameLbl?.text     = "Loading..."
        PaymentDatetimeLbl?.text = "..."
        TransactionIDLbl?.text   = "..."
    }

    // MARK: - 🛟 Fallback (API failed / not synced yet)
    func configureFallback(amount: Double,
                           studentName: String,
                           transactionId: String) {

        let formatter                   = NumberFormatter()
        formatter.numberStyle           = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        let amountText = formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"

        Paidamount?.text       = "₹\(amountText)"
        StudentnameLbl?.text   = studentName.isEmpty ? "--" : studentName
        TransactionIDLbl?.text = transactionId.isEmpty ? "--" : transactionId

        let df        = DateFormatter()
        df.dateFormat = "dd MMM yyyy, hh:mm a"
        PaymentDatetimeLbl?.text = df.string(from: Date())

        print("🛟 Receipt rendered using LOCAL fallback data")
    }
}
