//
//  CustompaymentVCTableViewCell.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 23/06/26.
//

import UIKit

class CustompaymentVCTableViewCell: UITableViewCell {

    @IBOutlet weak var EnteramountTextField: UITextField!
    @IBOutlet weak var PayButton: UIButton!
    @IBOutlet weak var ViewfullscheduleButton: UIButton!
    @IBOutlet weak var ViewalltransactionsButton: UIButton!
    @IBOutlet weak var Switch: UISwitch!

    // MARK: - Closures

    var onSwitchOff: (() -> Void)?
    var onViewFullScheduleTap: (() -> Void)?
    var onViewAllTransactionsTap: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        setupActions()
    }

    override func setSelected(
        _ selected: Bool,
        animated: Bool
    ) {
        super.setSelected(
            selected,
            animated: animated
        )
    }

    // MARK: Setup

    private func setupActions() {

        Switch.addTarget(
            self,
            action: #selector(switchChanged),
            for: .valueChanged
        )

        ViewfullscheduleButton.addTarget(
            self,
            action: #selector(viewFullScheduleTapped),
            for: .touchUpInside
        )

        ViewalltransactionsButton.addTarget(
            self,
            action: #selector(viewAllTransactionsTapped),
            for: .touchUpInside
        )
    }

    // MARK: Actions

    @objc private func switchChanged() {

        if !Switch.isOn {

            onSwitchOff?()
        }
    }

    @objc private func viewFullScheduleTapped() {

        onViewFullScheduleTap?()
    }

    @objc private func viewAllTransactionsTapped() {

        onViewAllTransactionsTap?()
    }
}
