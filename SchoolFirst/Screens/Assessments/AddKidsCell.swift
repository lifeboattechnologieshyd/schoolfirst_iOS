//
//  AddKidsCell.swift
//  SchoolFirst
//
//  Created by Lifeboat on 08/11/25.
//

import UIKit

class AddKidsCell: UITableViewCell {
    
    @IBOutlet weak var addKidButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func addKidButton(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name("AddKidTapped"), object: nil)
    }
}

