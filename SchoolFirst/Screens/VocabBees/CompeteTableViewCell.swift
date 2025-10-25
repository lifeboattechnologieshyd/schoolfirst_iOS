//
//  CompeteTableViewCell.swift
//  SchoolFirst
//
//  Created by Lifeboat on 20/10/25.
//

import UIKit



class CompeteTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var competeImage: UIImageView!
    @IBOutlet weak var blackImage: UIImageView!
    @IBOutlet weak var competeLabel: UILabel!
    @IBOutlet weak var sundayLabel: UILabel!
    @IBOutlet weak var minutesLabel: UILabel!
    @IBOutlet weak var graphImage: UIImageView!
    @IBOutlet weak var yellowImage: UIImageView!
    @IBOutlet weak var todayLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var registerLabel: UILabel!
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var registerView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        registerView.layer.cornerRadius = 10
        registerView.layer.masksToBounds = true
    }
}
