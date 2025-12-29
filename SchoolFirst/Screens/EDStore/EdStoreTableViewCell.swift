//
//  EdStoreTableViewCell.swift
//  SchoolFirst
//
//  Created by Lifeboat on 23/10/25.
//

import UIKit

protocol EdStoreCellDelegate: AnyObject {
    func didTapImage(in cell: EdStoreTableViewCell)
}


class EdStoreTableViewCell: UITableViewCell {
    
    @IBOutlet weak var bgVw: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var discountLbl: UILabel!
    @IBOutlet weak var imgVw: UIImageView!
    
    weak var delegate: EdStoreCellDelegate?
        
        override func awakeFromNib() {
            super.awakeFromNib()
            
             bgVw.addCardShadow()
            
             imgVw.isUserInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
            imgVw.addGestureRecognizer(tapGesture)
        }
        
        @objc private func imageTapped() {
            delegate?.didTapImage(in: self)
        }
    }

