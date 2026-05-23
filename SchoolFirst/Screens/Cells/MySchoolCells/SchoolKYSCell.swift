//
//  SchoolKYSCell.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 13/09/25.
//

import UIKit

class SchoolKYSCell: UITableViewCell {

    @IBOutlet weak var imgVw: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblInfo: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(info: SchoolInfo) {
        self.lblInfo.text = info.shortDescription
        self.lblTitle.text = info.title
        self.imgVw.loadImage(url: info.image)
    }
    
}
