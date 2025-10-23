//
//  CurriculumConceptCell.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 24/10/25.
//

import UIKit

class CurriculumConceptCell: UITableViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var imgVw: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
