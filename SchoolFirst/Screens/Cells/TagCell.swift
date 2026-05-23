//
//  TagCell.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 19/08/25.
//

import UIKit

class TagCell: UICollectionViewCell {

    @IBOutlet weak var lblText: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    func setupUI() {
        contentView.backgroundColor = UIColor(hex: "#F5F5F5")
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.clear.cgColor
        
        lblText.numberOfLines = 1
        lblText.textAlignment = .center
    }
    
    func setSelected(_ selected: Bool) {
        if selected {
            contentView.backgroundColor = UIColor(hex: "#CDE9FA")
            contentView.layer.borderColor = UIColor(hex: "#007AFF")?.cgColor
            lblText.textColor = UIColor(hex: "#007AFF")
        } else {
            contentView.backgroundColor = UIColor(hex: "#F5F5F5")
            contentView.layer.borderColor = UIColor.clear.cgColor
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        setSelected(false)
        lblText.text = nil
    }
}
