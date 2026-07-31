//
//  TRSPTcurrentmonthfeeUITableViewCell1.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 29/07/26.
//

import UIKit

class TRSPTcurrentmonthfeeUITableViewCell1: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var SubscriptiontypeLbl: UILabel!
    @IBOutlet weak var AmountLbl: UILabel!
    @IBOutlet weak var FeetypeLbl: UILabel!
    @IBOutlet weak var ImageView: UIImageView!

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        FeetypeLbl.text         = nil
        SubscriptiontypeLbl.text = nil
        AmountLbl.text          = nil
        ImageView.image         = nil
    }

    // MARK: - UI Setup
    private func setupUI() {
        // Icon rounded background (styled on ImageView itself)
        ImageView.layer.cornerRadius = 12
        ImageView.clipsToBounds      = true
        ImageView.contentMode        = .center

        // Fee type — semibold black
        FeetypeLbl.font      = UIFont.systemFont(ofSize: 17, weight: .semibold)
        FeetypeLbl.textColor = .black

        // Subscription type — gray subtitle
        SubscriptiontypeLbl.font      = UIFont.systemFont(ofSize: 14, weight: .regular)
        SubscriptiontypeLbl.textColor = .darkGray

        // Amount — bold blue
        AmountLbl.font      = UIFont.systemFont(ofSize: 17, weight: .bold)
        AmountLbl.textColor = UIColor.systemBlue
    }

    // MARK: - Configure
    func configure(with item: CurrentMonthFeeItem) {
        FeetypeLbl.text          = item.feeType
        SubscriptiontypeLbl.text = item.subscriptionType
        AmountLbl.text           = item.amount

        ImageView.image          = UIImage(systemName: item.iconName)
        ImageView.tintColor      = item.iconTintColor
        ImageView.backgroundColor = item.iconBgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
