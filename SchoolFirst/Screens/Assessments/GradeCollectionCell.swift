//
//  GradeCollectionCell.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 11/10/25.
//

import UIKit

class GradeCollectionCell: UICollectionViewCell {

    @IBOutlet weak var lblGrade: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        lblGrade.addPadding(top: 4, left: 8, bottom: 4, right: 8)
    }

}
