//
//  GalleryCell.swift
//  SchoolFirst
//
//  Created by Lifeboat on 25/10/25.
//

import UIKit



class GalleryCell: UITableViewCell {
    
    @IBOutlet weak var mainVw: UIView!
    @IBOutlet weak var imgVw: UIImageView!
    @IBOutlet weak var paintingLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mainVw.layer.cornerRadius = 10
        mainVw.layer.masksToBounds = true
    }
    
}
