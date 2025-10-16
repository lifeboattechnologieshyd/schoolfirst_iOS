//
//  SchoolInfoCell.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 12/09/25.
//

import UIKit

class SchoolInfoCell: UITableViewCell {

    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblWebsite: UILabel!
    @IBOutlet weak var lblMobile: UILabel!
    @IBOutlet weak var lblSchoolName: UILabel!
    @IBOutlet weak var imgLogo: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()

        imgLogo.applyCardShadow()
        
        lblSchoolName.text = UserManager.shared.user?.schools.first?.schoolName ?? ""
        
        lblEmail.text = UserManager.shared.user?.schools.first?.email ?? ""
        
        lblMobile.text = UserManager.shared.user?.schools.first?.phoneNumber ?? ""
        
        lblWebsite.text = UserManager.shared.user?.schools.first?.website ?? ""
        
        lblAddress.text = UserManager.shared.user?.schools.first?.address ?? "" + ", \(UserManager.shared.user?.schools.first?.district ?? "")" + ", \(UserManager.shared.user?.schools.first?.state ?? "")"
        
        imgLogo.loadImage(url: UserManager.shared.user?.schools.first?.fullLogo ?? "")
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
}
