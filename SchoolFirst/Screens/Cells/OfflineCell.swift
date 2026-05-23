//
//  OfflineCell.swift
//  SchoolFirst
//
//  Created by Lifeboat on 07/01/26.
//

import UIKit

class OfflineCell: UITableViewCell {
    
    @IBOutlet weak var lblAudience: UILabel!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var subjectLbl: UILabel!
    @IBOutlet weak var timePeriod: UILabel!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var enrollBtn: UIButton!
    @IBOutlet weak var noofslotsLbl: UILabel!
    @IBOutlet weak var lblCourseName: UILabel!
    @IBOutlet weak var imgCourse: UIImageView!
    @IBOutlet weak var bgView: UIView!



    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.addCardShadow()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
