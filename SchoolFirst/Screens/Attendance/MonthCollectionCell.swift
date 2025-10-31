//
//  MonthCollectionCell.swift
//  SchoolFirst
//
//  Created by Lifeboat on 28/10/25.
//

import UIKit

class MonthCollectionCell: UICollectionViewCell {

    @IBOutlet weak var monthLbl: UILabel!
    @IBOutlet weak var bgVw: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//         bgVw.backgroundColor = UIColor(red: 203/255, green: 229/255, blue: 253/255, alpha: 1.0) // #CBE5FD
        bgVw.layer.cornerRadius = 16
        bgVw.layer.masksToBounds = true  
    }
}

