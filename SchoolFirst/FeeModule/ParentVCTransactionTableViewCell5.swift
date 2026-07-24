//
//  ParentVCTransactionTableViewCell5.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 23/07/26.
//

import UIKit

class ParentVCTransactionTableViewCell5: UITableViewCell {
    @IBOutlet weak var ViewfullscheduleButton: UIButton!
    @IBOutlet weak var ViewalltransactionsButton: UIButton!
    
    // MARK: - Callbacks
    var onViewAllTransactionsTapped: (() -> Void)?
    var onViewFullScheduleTapped: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        ViewalltransactionsButton.addTarget(self, action: #selector(viewAllTransactionsTapped), for: .touchUpInside)
        ViewfullscheduleButton.addTarget(self, action: #selector(viewFullScheduleTapped), for: .touchUpInside)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    // MARK: - Button Actions
    @objc private func viewAllTransactionsTapped() {
        onViewAllTransactionsTapped?()
    }
    
    @objc private func viewFullScheduleTapped() {
        onViewFullScheduleTapped?()
    }
}
