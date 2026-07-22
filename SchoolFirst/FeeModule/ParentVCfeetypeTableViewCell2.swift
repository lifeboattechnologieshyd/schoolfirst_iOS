//
//  ParentVCfeetypeTableViewCell2.swift
//

import UIKit

class ParentVCfeetypeTableViewCell2: UITableViewCell {

    @IBOutlet weak var PayButton: UIButton!
    @IBOutlet weak var TermtotalpayableamountLbl: UILabel!
    @IBOutlet weak var InstallmentLbl: UILabel!
    @IBOutlet weak var FeetypeLbl: UILabel!
    @IBOutlet weak var FeetypeLbl1: UILabel!

    var onPayTapped: ((PendingFeeItem) -> Void)?
    private var feeItem: PendingFeeItem?

    override func awakeFromNib() {
        super.awakeFromNib()
        PayButton.addTarget(self, action: #selector(payButtonTapped), for: .touchUpInside)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        FeetypeLbl.text = nil
        FeetypeLbl1.text = nil
        InstallmentLbl.text = nil
        TermtotalpayableamountLbl.text = nil
        feeItem = nil
        onPayTapped = nil
    }

    func configure(with item: PendingFeeItem) {
        self.feeItem = item
        FeetypeLbl.text = item.feeType
        FeetypeLbl1.text = item.feeType
        InstallmentLbl.text = item.installment
        TermtotalpayableamountLbl.text = "₹\(formatAmount(item.payableAmount))"
    }

    @objc private func payButtonTapped() {
        guard let feeItem = feeItem else { return }
        onPayTapped?(feeItem)
    }

    private func formatAmount(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
