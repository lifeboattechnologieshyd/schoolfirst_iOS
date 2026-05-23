//
//  TabCell.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 20/07/25.
//

import UIKit

class TabCell: UICollectionViewCell {
    
    @IBOutlet weak var selectedView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var img: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func loadCell(option: [String: Any]) {
        lblTitle.text = option["name"] as? String
        
        if let imageName = option["image"] as? String {
            img.image = UIImage(named: imageName)
        } else {
            img.image = nil
        }
    }
}
