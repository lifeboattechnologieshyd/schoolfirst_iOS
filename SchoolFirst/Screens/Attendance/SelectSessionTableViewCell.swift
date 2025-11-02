//
//  SelectSessionTableViewCell.swift
//  SchoolFirst
//
//  Created by Lifeboat on 31/10/25.
//

import UIKit

class SelectSessionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var firstVw: UIView!
    @IBOutlet weak var reasonVw: UIView!
    @IBOutlet weak var downarrowButton: UIButton!
    @IBOutlet weak var secondVw: UIView!
    
    override func awakeFromNib() {
            super.awakeFromNib()
            setupViews()
        }
        
        private func setupViews() {
            [firstVw, secondVw].forEach {
                $0?.layer.cornerRadius = 16
                $0?.layer.masksToBounds = true
            }
            
            reasonVw.layer.cornerRadius = 5
            reasonVw.layer.shadowColor = UIColor.black.cgColor
            reasonVw.layer.shadowOpacity = 0.2
            reasonVw.layer.shadowOffset = CGSize(width: 0, height: 2)
            reasonVw.layer.shadowRadius = 4
            reasonVw.layer.masksToBounds = false
        }
    }
