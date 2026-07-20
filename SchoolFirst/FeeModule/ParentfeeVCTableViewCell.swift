//
//  ParentfeeVCTableViewCell.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 23/06/26.
//

import UIKit

class ParentfeeVCTableViewCell: UITableViewCell {

    @IBOutlet weak var ViewScheduleButton: UIButton!
    @IBOutlet weak var ViewalltransactionButton: UIButton!
    @IBOutlet weak var Switch: UISwitch!

    // MARK: - Closures

    var onSwitchOn: (() -> Void)?
    var onSwitchOff: (() -> Void)?

    var onViewScheduleTap: (() -> Void)?
    var onViewAllTransactionTap: (() -> Void)?

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

        ViewScheduleButton.addTarget(
            self,
            action: #selector(viewScheduleTapped),
            for: .touchUpInside
        )

        ViewalltransactionButton.addTarget(
            self,
            action: #selector(viewAllTransactionTapped),
            for: .touchUpInside
        )
    }

    // MARK: Actions

    @objc private func switchChanged() {

        if Switch.isOn {

            onSwitchOn?()

        } else {

            onSwitchOff?()
        }
    }

    @objc private func viewScheduleTapped() {

        onViewScheduleTap?()
    }

    @objc private func viewAllTransactionTapped() {

        onViewAllTransactionTap?()
    }
}
