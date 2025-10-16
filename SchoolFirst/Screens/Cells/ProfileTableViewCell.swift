//
//  ProfileTableViewCell.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 21/08/25.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var lblMobile: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    
    
    var onShareClick: (() -> Void)?

    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.applyCardShadow()
        shareView.applyCardShadow()
        lblName.text = UserManager.shared.user?.username
        lblMobile.text = "\(UserManager.shared.user?.mobile ?? 0)"
        imgView.loadImage(url: UserManager.shared.user?.profileImage ?? "", placeHolderImage: "dummy_kid_profile_pic")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
    @IBAction func onClickEdit(_ sender: UIButton) {
        
    }
    
    @IBAction func onClickShare(_ sender: UIButton) {
        onShareClick!()
    }
}
