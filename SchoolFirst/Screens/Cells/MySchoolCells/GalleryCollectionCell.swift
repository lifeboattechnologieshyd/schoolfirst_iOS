//
//  GalleryCollectionCell.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 13/09/25.
//

import UIKit

class GalleryCollectionCell: UICollectionViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgVw: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    func config(gallery: EventGallery){
        bgView.applyCardShadow()
        self.lblDate.text = gallery.eventDate + " | " + "\(gallery.numberOfPics)"
        self.lblName.text = gallery.eventName
        self.imgVw.loadImage(url: gallery.thumbnailImages.first ?? "")
    }

}
