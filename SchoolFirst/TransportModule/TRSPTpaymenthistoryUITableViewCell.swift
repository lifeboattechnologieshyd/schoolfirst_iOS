//
//  TRSPTpaymenthistoryUITableViewCell.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 29/07/26.
//

import UIKit

class TRSPTpaymenthistoryUITableViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var backgroundview: UIView!
    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var PaymentmonthLbl: UILabel!
    @IBOutlet weak var TransactionIDLbl: UILabel!
    @IBOutlet weak var DateLbl: UILabel!
    @IBOutlet weak var AmountLbl: UILabel!

    // MARK: - Status Label (created programmatically — matches Figma "SUCCESS")
    private let statusLabel = UILabel()

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        PaymentmonthLbl.text  = nil
        TransactionIDLbl.text = nil
        DateLbl.text          = nil
        AmountLbl.text        = nil
        statusLabel.text      = nil
        ImageView.image       = nil
    }

    // MARK: - UI Setup
    private func setupUI() {
        // Card background
        backgroundview.layer.cornerRadius = 16
        backgroundview.clipsToBounds      = true

        // Checkmark icon — dark teal circle like Figma
        ImageView.layer.cornerRadius = 22
        ImageView.clipsToBounds      = true
        ImageView.contentMode        = .center
        ImageView.backgroundColor    = UIColor(
            red: 11/255, green: 43/255, blue: 60/255, alpha: 1.0
        ).withAlphaComponent(0.08)
        ImageView.tintColor          = UIColor(red: 11/255, green: 43/255, blue: 60/255, alpha: 1.0)

        // Payment month — semibold black
        PaymentmonthLbl.font      = UIFont.systemFont(ofSize: 17, weight: .semibold)
        PaymentmonthLbl.textColor = .black

        // Date & Transaction ID — gray subtitle
        DateLbl.font              = UIFont.systemFont(ofSize: 14, weight: .regular)
        DateLbl.textColor         = .darkGray
        TransactionIDLbl.font     = UIFont.systemFont(ofSize: 14, weight: .regular)
        TransactionIDLbl.textColor = .darkGray

        // Amount — bold black
        AmountLbl.font      = UIFont.systemFont(ofSize: 17, weight: .bold)
        AmountLbl.textColor = .black

        // Status label — placed under amount, right aligned
        statusLabel.font          = UIFont.systemFont(ofSize: 12, weight: .semibold)
        statusLabel.textColor     = UIColor.systemGreen
        statusLabel.textAlignment = .right
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        backgroundview.addSubview(statusLabel)

        NSLayoutConstraint.activate([
            statusLabel.trailingAnchor.constraint(equalTo: AmountLbl.trailingAnchor),
            statusLabel.topAnchor.constraint(equalTo: AmountLbl.bottomAnchor, constant: 4)
        ])
    }

    // MARK: - Configure
    func configure(with item: PaymentHistoryItem) {
        PaymentmonthLbl.text  = item.paymentMonth
        DateLbl.text          = item.date
        TransactionIDLbl.text = "ID: \(item.transactionID)"
        AmountLbl.text        = item.amount
        statusLabel.text      = item.status

        // Checkmark icon
        ImageView.image = UIImage(
            systemName: "checkmark",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        )

        // Status color
        switch item.status.uppercased() {
        case "SUCCESS":
            statusLabel.textColor = UIColor(red: 11/255, green: 43/255, blue: 60/255, alpha: 1.0)
        case "PENDING":
            statusLabel.textColor = .systemOrange
        case "FAILED":
            statusLabel.textColor = .systemRed
        default:
            statusLabel.textColor = .darkGray
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
