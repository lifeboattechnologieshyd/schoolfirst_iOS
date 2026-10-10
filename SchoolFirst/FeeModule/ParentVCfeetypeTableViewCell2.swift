//  ParentVCfeetypeTableViewCell2.swift
//  SchoolFirst
//

import UIKit

class ParentVCfeetypeTableViewCell2: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var PayButton: UIButton!
    @IBOutlet weak var TermtotalpayableamountLbl: UILabel!
    @IBOutlet weak var InstallmentLbl: UILabel!
    @IBOutlet weak var FeetypeLbl: UILabel!
    @IBOutlet weak var FeetypeLbl1: UILabel!

    // MARK: - Callback
    var onPayTapped: ((PendingFeeItem) -> Void)?
    private var feeItem: PendingFeeItem?

    // MARK: - Hit Test Override (ensures PayButton is always tappable regardless of contentView bounds)
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let payButton = PayButton, !payButton.isHidden && payButton.isUserInteractionEnabled && payButton.alpha > 0.01 {
            let pointInButton = payButton.convert(point, from: self)
            if payButton.bounds.contains(pointInButton) {
                return payButton
            }
        }
        return super.hitTest(point, with: event)
    }

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        isUserInteractionEnabled = true
        contentView.isUserInteractionEnabled = true
        setupPayButtonAction()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        FeetypeLbl.text                = nil
        FeetypeLbl1.text               = nil
        InstallmentLbl.text            = nil
        TermtotalpayableamountLbl.text = nil
    }

    // MARK: - Configure
    func configure(with item: PendingFeeItem, academicYear: String? = nil) {
        self.feeItem = item
        FeetypeLbl.text                = item.feeType
        FeetypeLbl1.text               = item.feeType
        if !item.installment.isEmpty {
            InstallmentLbl.text = item.installment
        } else if let academicYear = academicYear, !academicYear.isEmpty {
            InstallmentLbl.text = academicYear
        } else if let year = item.academicYear?.name, !year.isEmpty {
            InstallmentLbl.text = year
        } else {
            InstallmentLbl.text = nil
        }
        TermtotalpayableamountLbl.text = "₹\(formatAmount(item.payableAmount))"
        setupPayButtonAction()
    }

    private func setupPayButtonAction() {
        guard let button = PayButton else { return }
        button.isUserInteractionEnabled = true
        button.removeTarget(nil, action: nil, for: .allEvents)
        button.addTarget(self,
                         action: #selector(payButtonTapped(_:)),
                         for: .touchUpInside)
    }

    // MARK: - Action
    @objc private func payButtonTapped(_ sender: UIButton) {
        print("🔘 [ParentVCfeetypeTableViewCell2] Pay button tapped!")
        guard let feeItem = feeItem else {
            print("⚠️ feeItem is nil in cell")
            return
        }
        if let onPayTapped = onPayTapped {
            onPayTapped(feeItem)
        } else {
            print("⚠️ onPayTapped callback is nil")
        }
    }

    // MARK: - Helper
    private func formatAmount(_ value: Double) -> String {
        let formatter                   = NumberFormatter()
        formatter.numberStyle           = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
