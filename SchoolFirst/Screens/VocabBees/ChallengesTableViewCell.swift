//
//  StudentsListTableViewCell.swift
//  SchoolFirst
//
//  Created by Lifeboat on 20/10/25.
//

import UIKit

class  ChallengesTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var challengeLabel: UILabel!
    @IBOutlet weak var blackImage: UIImageView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var viewChallengesLabel: UILabel!
    @IBOutlet weak var excelLabel: UILabel!
    @IBOutlet weak var onechallengeLabel: UILabel!
    @IBOutlet weak var ChallengeImage: UIImageView!
    @IBOutlet weak var bgVIew: UIView!
    
    
    override func awakeFromNib() {
            super.awakeFromNib()
         }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
             circleView.layer.cornerRadius = circleView.frame.width / 2
            circleView.clipsToBounds = true
        }
    }
