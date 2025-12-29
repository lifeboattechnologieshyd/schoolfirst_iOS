//
//  DescriptionTableViewCell.swift
//  SchoolFirst
//
//  Created by Lifeboat on 23/10/25.
//

import UIKit

class DescriptionTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var interestingLbl: UILabel!
    @IBOutlet weak var mrpLbl: UILabel!
    
    @IBOutlet weak var strikeOutPrice: UILabel!
    @IBOutlet weak var descriptionTv: UITextView!
    @IBOutlet weak var strikeLineImg: UIImageView!
    @IBOutlet weak var variant1: UILabel!
    @IBOutlet weak var variant2: UILabel!
    @IBOutlet weak var aboutLbl: UILabel!
    @IBOutlet weak var blueVw2: UIView!
    @IBOutlet weak var blueVw: UIView!
    @IBOutlet weak var sizesLbl: UILabel!
    @IBOutlet weak var offLbl: UILabel!
    @IBOutlet weak var amount2Lbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
}
