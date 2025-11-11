//
//  QuestionCell.swift
//  SchoolFirst
//
//  Created by Lifeboat on 11/11/25.
//

import UIKit

class QuestionCell: UICollectionViewCell {

    @IBOutlet weak var optionE: UIButton!
    @IBOutlet weak var optionD: UIButton!
    @IBOutlet weak var optionC: UIButton!
    @IBOutlet weak var optionB: UIButton!
    @IBOutlet weak var optionA: UIButton!
    @IBOutlet weak var Description: UILabel!
    @IBOutlet weak var Question: UILabel!
    @IBOutlet weak var QuestionNo: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
