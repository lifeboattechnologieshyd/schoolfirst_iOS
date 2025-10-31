//
//  gradeCollectionViewCell.swift
//  SchoolFirst
//
//  Created by Lifeboat on 20/10/25.
//

import UIKit



class gradeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var clsView: UIView!
    @IBOutlet weak var clsLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        clsView.applyCardShadow()
    }
        
       
    }


