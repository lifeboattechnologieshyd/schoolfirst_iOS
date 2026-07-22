//
//  ParentVCTransactionTableViewCell4.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 21/07/26.
//

import UIKit

class ParentVCTransactionTableViewCell4: UITableViewCell {

    @IBOutlet weak var ViewfullscheduleButton: UIButton!
    @IBOutlet weak var ViewalltransactionsButton: UIButton!

    // MARK: - Callbacks

    var onViewAllTransactionsTapped: (() -> Void)?
    var onViewFullScheduleTapped: (() -> Void)?

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()

        ViewalltransactionsButton.addTarget(
            self,
            action: #selector(viewAllTransactionsTapped),
            for: .touchUpInside
        )

        ViewfullscheduleButton.addTarget(
            self,
            action: #selector(viewFullScheduleTapped),
            for: .touchUpInside
        )
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onViewAllTransactionsTapped = nil
        onViewFullScheduleTapped = nil
    }

    override func setSelected(
        _ selected: Bool,
        animated: Bool
    ) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: - Button Actions

    @objc private func viewAllTransactionsTapped() {
        onViewAllTransactionsTapped?()
    }

    @objc private func viewFullScheduleTapped() {
        onViewFullScheduleTapped?()
    }
}
