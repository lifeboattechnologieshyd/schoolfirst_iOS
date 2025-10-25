//
//  GalleryCell.swift
//  SchoolFirst
//
//  Created by Lifeboat on 25/10/25.
//

import UIKit

class GalleryCell: UITableViewCell {

    @IBOutlet weak var mainVw: UIView!
    @IBOutlet weak var imgVw: UIView!
    @IBOutlet weak var paintingLbl: UIView!
    @IBOutlet weak var dateLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
