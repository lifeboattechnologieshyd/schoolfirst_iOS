//
//  StudentsListTableViewCell.swift
//  SchoolFirst
//
//  Created by Lifeboat on 20/10/25.
//

import UIKit

protocol ChallengesTableViewCellDelegate: AnyObject {
    func didTapNextButton()
}

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
            
            circleView.layer.cornerRadius = 10   
            circleView.layer.masksToBounds = true
            }
            
            
    weak var delegate: ChallengesTableViewCellDelegate?
        
    @IBAction func nextButtonTapped(_ sender: Any) {
    delegate?.didTapNextButton()
        }
    }

        
