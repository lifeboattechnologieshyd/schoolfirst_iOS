//
//  SchoolBannerCell.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 12/09/25.
//

import UIKit

class SchoolBannerCell: UITableViewCell {
    var onBackClick: (() -> Void)?
    @IBOutlet weak var logoImg: UIImageView!
    @IBOutlet weak var cover_pic: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.cover_pic.loadImage(url: UserManager.shared.user?.schools.first?.coverPic ?? "")
        self.logoImg.loadImage(url: UserManager.shared.user?.schools.first?.smallLogo ?? "")
    }
    
    @IBAction func onClickBack(_ sender: Any) {
        self.onBackClick!()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
}
