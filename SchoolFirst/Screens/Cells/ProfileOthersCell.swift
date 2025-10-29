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

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bgView.applyCardShadow()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onClickDelete(_ sender: UIButton) {
        self.onClickDelete!()
    }
    @IBAction func onClickLogout(_ sender: UIButton) {
        onLogoutTapped?()
    }
}


