//
//  HomeWorkCell.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 05/09/25.
//

import UIKit

class HomeWorkCell: UITableViewCell {

    @IBOutlet weak var lblCompletedstatus: UILabel!
    @IBOutlet weak var lblDeadline: UILabel!
    @IBOutlet weak var colVw: UICollectionView!
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onClickViewAll(_ sender: UIButton) {
        
    }
}


