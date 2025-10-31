//
//  MultipleCellOne.swift
//  SchoolFirst
//
//  Created by Lifeboat on 31/10/25.
//

import UIKit

class MultipleCellOne: UITableViewCell {
    
    @IBOutlet weak var shravVw: UIView!
    @IBOutlet weak var abhiVw: UIView!
    
    @IBOutlet weak var dateVw: UIView!
    @IBOutlet weak var secondVw: UIView!
    @IBOutlet weak var firstVw: UIView!
    @IBOutlet weak var halfVw: UIView!
    @IBOutlet weak var fullVw: UIView!
    @IBOutlet weak var multipleVw: UIView!
    @IBOutlet weak var singleVw: UIView!
    
    override func awakeFromNib() {
            super.awakeFromNib()
            
             [singleVw, multipleVw, dateVw].forEach {
                $0?.layer.cornerRadius = 8
                $0?.layer.shadowColor = UIColor.black.cgColor
                $0?.layer.shadowOpacity = 0.2
                $0?.layer.shadowOffset = CGSize(width: 0, height: 2)
                $0?.layer.shadowRadius = 4
                $0?.layer.masksToBounds = false
            }
            
             abhiVw.layer.cornerRadius = 25
            abhiVw.layer.borderWidth = 1
            abhiVw.layer.borderColor = UIColor(red: 11/255, green: 86/255, blue: 154/255, alpha: 1).cgColor // #0B569A
            
            shravVw.layer.cornerRadius = 25
            shravVw.layer.borderWidth = 1
            shravVw.layer.borderColor = UIColor(red: 203/255, green: 229/255, blue: 253/255, alpha: 1).cgColor // #CBE5FD
            
            // datevw.layer.cornerRadius = 5
           // datevw.layer.masksToBounds = true
            
             [fullVw, halfVw, firstVw, secondVw].forEach {
                $0?.layer.cornerRadius = 16
                $0?.layer.masksToBounds = true
            }
        }
    }
