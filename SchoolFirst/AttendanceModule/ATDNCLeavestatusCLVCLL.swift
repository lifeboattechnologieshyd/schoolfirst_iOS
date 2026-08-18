//
//  ATDNCLeavestatusCLVCLL.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 14/08/26.
//

import UIKit

class ATDNCLeavestatusCLVCLL: UICollectionViewCell {

    @IBOutlet weak var leavestatustitle: UILabel!
    @IBOutlet weak var Cardbackgroundview: UIView!
    @IBOutlet weak var NumberofdaysLbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        // Card style matching the image
        Cardbackgroundview.layer.cornerRadius = 12
        Cardbackgroundview.layer.borderWidth = 1
        Cardbackgroundview.layer.borderColor = UIColor(red: 255/255,
                                                       green: 224/255,
                                                       blue: 200/255,
                                                       alpha: 1.0).cgColor
        Cardbackgroundview.backgroundColor = UIColor(red: 255/255,
                                                     green: 250/255,
                                                     blue: 245/255,
                                                     alpha: 1.0)
        Cardbackgroundview.clipsToBounds = true

        // Number label style
        NumberofdaysLbl.font = UIFont.boldSystemFont(ofSize: 22)
        NumberofdaysLbl.textAlignment = .center

        // Title label style
        leavestatustitle.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        leavestatustitle.textColor = .darkGray
        leavestatustitle.textAlignment = .center
    }
}
