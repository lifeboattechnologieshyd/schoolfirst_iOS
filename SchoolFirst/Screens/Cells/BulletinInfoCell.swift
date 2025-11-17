//
//  BulletinInfoCell.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 15/09/25.
//

import UIKit

class BulletinInfoCell: UITableViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgVw: UIImageView!
    @IBOutlet weak var txtViewDescription: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
    func config(bulletin: Bulletin){
        self.lblTitle.attributedText = bulletin.cachedTitleHTML
        self.txtViewDescription.attributedText = bulletin.cachedDescriptionHTML
        self.imgVw.loadImage(url: bulletin.images?.first ?? "")
    }
}
