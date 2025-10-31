//
//  MultipleCellTwo.swift
//  SchoolFirst
//
//  Created by Lifeboat on 31/10/25.
//

import UIKit

class MultipleCellTwo: UITableViewCell {
    
    @IBOutlet weak var reasonVw: UIView!
    @IBOutlet weak var tellusTf: UITextField!
    @IBOutlet weak var halfVw: UIView!
    @IBOutlet weak var fullVw: UIView!
    @IBOutlet weak var dateVw: UIView!
    
    override func awakeFromNib() {
            super.awakeFromNib()
        
        [fullVw, halfVw].forEach {
           $0?.layer.cornerRadius = 16
           $0?.layer.masksToBounds = true
       }
            
            [dateVw, reasonVw, tellusTf].forEach {
                $0?.layer.cornerRadius = 5
                $0?.layer.shadowColor = UIColor.black.cgColor
                $0?.layer.shadowOpacity = 0.2
                $0?.layer.shadowOffset = CGSize(width: 0, height: 2)
                $0?.layer.shadowRadius = 4
                $0?.layer.masksToBounds = false
            }
        }
    }
