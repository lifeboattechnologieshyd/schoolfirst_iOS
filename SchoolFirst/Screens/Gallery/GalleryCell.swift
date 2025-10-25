//
//  GalleryCell.swift
//  SchoolFirst
//
//  Created by Lifeboat on 25/10/25.
//

import UIKit

protocol GalleryCellDelegate: AnyObject {
    func galleryCellDidTap(_ cell: GalleryCell)
}

class GalleryCell: UITableViewCell {
    
    @IBOutlet weak var mainVw: UIView!
    @IBOutlet weak var imgVw: UIImageView!
    @IBOutlet weak var paintingLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    weak var delegate: GalleryCellDelegate?

        override func awakeFromNib() {
            super.awakeFromNib()
            mainVw.layer.cornerRadius = 10
            mainVw.layer.masksToBounds = true

             let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
            imgVw.isUserInteractionEnabled = true
            imgVw.addGestureRecognizer(tapGesture)
        }

        @objc func imageTapped() {
            delegate?.galleryCellDidTap(self)
        }
    }
