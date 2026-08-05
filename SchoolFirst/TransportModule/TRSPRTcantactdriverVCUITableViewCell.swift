//
//  TRSPRTcantactdriverVCUITableViewCell.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 29/07/26.
//

import UIKit

// MARK: - Delegate Protocol for Navigation
protocol TRSPRTcantactdriverCellDelegate: AnyObject {
    func didTapMessageButton()
}

class TRSPRTcantactdriverVCUITableViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var MessageButton: UIButton!

    // MARK: - Delegate
    weak var delegate: TRSPRTcantactdriverCellDelegate?

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    // MARK: - Button Action
    @IBAction func MessageButtonTapped(_ sender: UIButton) {
        print("💬 Message button tapped")
        delegate?.didTapMessageButton()
    }
}
