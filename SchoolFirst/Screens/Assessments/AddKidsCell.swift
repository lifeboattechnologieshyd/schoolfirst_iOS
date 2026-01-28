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
    
    private var shouldShowCardShadow = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        shouldShowCardShadow = false
        bgVw.layer.shadowOpacity = 2
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if shouldShowCardShadow {
            bgVw.addCardShadow()
        } else {
            bgVw.layer.shadowOpacity = 2
        }
    }
    
    func configure(showCardShadow: Bool) {
        self.shouldShowCardShadow = showCardShadow
        setNeedsLayout()
    }
    
    @IBAction func addKidButton(_ sender: UIButton) {
        onAddKidTapped?()
    }
}
