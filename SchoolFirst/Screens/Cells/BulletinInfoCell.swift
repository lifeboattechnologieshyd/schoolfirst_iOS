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
        self.lblTitle.setHTML(bulletin.title, font: .lexend(.semiBold, size: 16))
        self.txtViewDescription.setHTML(bulletin.description ?? "", font: .lexend(.regular, size: 14))
        self.imgVw.loadImage(url: bulletin.images?.first ?? "")
    }
}
