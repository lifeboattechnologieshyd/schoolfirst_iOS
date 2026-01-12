//
//  AddKidsCell.swift
//  SchoolFirst
//
//  Created by Lifeboat on 08/11/25.
//

import UIKit

class AddKidsCell: UITableViewCell {
    
    @IBOutlet weak var addKidButton: UIButton!
    @IBOutlet weak var bgVw: UIView!
    
    var onAddKidTapped: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func addKidButton(_ sender: UIButton) {
        onAddKidTapped?()
    }
}
