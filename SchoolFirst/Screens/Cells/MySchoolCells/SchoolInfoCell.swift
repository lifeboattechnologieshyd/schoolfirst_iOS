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
        
        lblSchoolName.text = UserManager.shared.selectedSchool?.schoolName ?? ""
        
        lblEmail.text = UserManager.shared.selectedSchool?.email ?? ""
        
        lblMobile.text = UserManager.shared.selectedSchool?.phoneNumber ?? ""
        
        lblWebsite.text = UserManager.shared.selectedSchool?.website ?? ""
        
        lblAddress.text = UserManager.shared.selectedSchool?.address ?? "" + ", \(UserManager.shared.selectedSchool?.district ?? "")" + ", \(UserManager.shared.selectedSchool?.state ?? "")"
        
        imgLogo.loadImage(url: UserManager.shared.selectedSchool?.fullLogo ?? "")
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
}
