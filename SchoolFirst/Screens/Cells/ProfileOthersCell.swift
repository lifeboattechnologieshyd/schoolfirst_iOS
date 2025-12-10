//
//  ProfileOthersCell.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 21/08/25.
//

import UIKit

class ProfileOthersCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var Logout: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    var onClickDelete: (() -> Void)?
    var onLogoutTapped: (() -> Void)?
    
    var onPrivacyTapped: (() -> Void)?
    var onTermsTapped: (() -> Void)?
    var onRateUsTapped: (() -> Void)?
    var onContactUsTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.applyCardShadow()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func onClickDelete(_ sender: UIButton) {
        self.onClickDelete!()
    }
    @IBAction func onClickLogout(_ sender: UIButton) {
        onLogoutTapped?()
    }
    
    @IBAction func onClickPrivacy(_ sender: UIButton) {
        onPrivacyTapped?()
    }
    @IBAction func onClickTerms(_ sender: UIButton) {
        onTermsTapped?()
    }
    @IBAction func onClickRateUs(_ sender: UIButton) {
        onRateUsTapped?()
    }
    @IBAction func onClickContactUs(_ sender: UIButton) {
        onContactUsTapped?()
    }
}


