//
//  KeyboardCell.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 30/10/25.
//

import UIKit

class KeyboardCell: UICollectionViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var lblKey: UILabel!
    @IBOutlet weak var imgVw: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    func configure(with title: String) {
        if title == "Delete" {
            lblKey.text = "⌫"
            imgVw.contentMode = .scaleAspectFit
        } else if title == "Space" {
            lblKey.text = " Space "
            imgVw.contentMode = .scaleAspectFill
        }else{
            lblKey.text = title
            imgVw.contentMode = .scaleAspectFit

        }
        lblKey.layer.cornerRadius = 8
    }
    
    
    func configure(text: String, bgColor: UIColor, textColor: UIColor) {
        lblKey.text = text
        lblKey.textColor = textColor
//        bgView.backgroundColor = bgColor
    }

    // optional press animation helper
    func animatePress() {
        UIView.animate(withDuration: 0.09, animations: {
            self.contentView.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        }) { _ in
            UIView.animate(withDuration: 0.09) {
                self.contentView.transform = .identity
            }
        }
    }
}


