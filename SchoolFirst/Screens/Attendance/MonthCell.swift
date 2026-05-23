//
//  MonthCell.swift
//  SchoolFirst
//
//  Created by Lifeboat on 01/11/25.
//

import UIKit

class MonthCell: UICollectionViewCell {
    
    @IBOutlet weak var monthLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.layer.cornerRadius = 17
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.clear.cgColor
    }
    
    func configure(with month: String, isSelected: Bool) {
        monthLabel.text = month
        
        if isSelected {
            contentView.backgroundColor = UIColor(red: 11/255, green: 86/255, blue: 154/255, alpha: 1)
            
             if month.uppercased() == "ALL" {
                monthLabel.textColor = .black
            } else {
                monthLabel.textColor = .white
            }
            
        } else {
            contentView.backgroundColor = UIColor(red: 203/255, green: 229/255, blue: 253/255, alpha: 1)
            
             monthLabel.textColor = (month.uppercased() == "ALL") ? .black : .black
        }
    }
}

