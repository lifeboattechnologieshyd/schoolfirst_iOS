//
//  VocabBeeDateCell.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 29/10/25.
//

import UIKit

class VocabBeeDateCell: UITableViewCell {

    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setup(item : VocabeeDate){
        self.lblDate.text = "\(item.date)"
        self.lblDescription.text = "\(item.totalWords) Words | \(item.minutes) Min"
    }
    
}
