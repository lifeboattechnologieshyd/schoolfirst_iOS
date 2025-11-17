//
//  DetailsCell.swift
//  SchoolFirst
//
//  Created by Lifeboat on 15/11/25.
//

import UIKit

class DetailsCell: UITableViewCell {
    
    @IBOutlet weak var lblDateDesign: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var desTv: UITextView!
    @IBOutlet weak var imgVw: UIImageView!
    
    @IBOutlet weak var lblTime: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}

