//
//  gradeCollectionViewCell.swift
//  SchoolFirst
//
//  Created by Lifeboat on 20/10/25.
//

import UIKit

protocol GradeCellDelegate: AnyObject {
    func didTapNextButton(cell: gradeCollectionViewCell)
}

class gradeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var clsView: UIView!
    @IBOutlet weak var clsLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        clsView.layer.cornerRadius = 12
        clsView.layer.masksToBounds = false
        clsView.layer.shadowColor = UIColor.black.cgColor
        clsView.layer.shadowOpacity = 0.25
        clsView.layer.shadowOffset = CGSize(width: 0, height: 3)
        clsView.layer.shadowRadius = 6        
    }
    weak var delegate: GradeCellDelegate?
        
        @IBAction func nextButtonTapped(_ sender: UIButton) {
            delegate?.didTapNextButton(cell: self)
        }
    }


