//
//  PracticeTableViewCell.swift
//  SchoolFirst
//
//  Created by Lifeboat on 20/10/25.
//

import UIKit



class PracticeTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var beatImage: UILabel!
    @IBOutlet weak var completedImage: UILabel!
    @IBOutlet weak var wordsImage: UILabel!
    @IBOutlet weak var practiceImage: UIImageView!
    
    @IBOutlet weak var playnowView: UIView!
    @IBOutlet weak var playnoeLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        playnowView.layer.cornerRadius = 10
        playnowView.layer.masksToBounds = true
    }
    
}
    
    

