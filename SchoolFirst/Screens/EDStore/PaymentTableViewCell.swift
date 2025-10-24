//
//  PaymentTableViewCell.swift
//  SchoolFirst
//
//  Created by Lifeboat on 23/10/25.
//

import UIKit

class PaymentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imgVw: UIImageView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var selectLbl: UIView!
    @IBOutlet weak var selectVw: UIView!
    @IBOutlet weak var bigVw: UIView!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var redVw: UIView!
    @IBOutlet weak var quantityVw: UIView!
    @IBOutlet weak var blueVw: UIView!
    @IBOutlet weak var sizeVw: UIView!
    @IBOutlet weak var quantityLbl: UILabel!
    @IBOutlet weak var managingLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupQuantityView()
        setupRoundedBorderedViews()
        setupSelectView()
     }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        selectVw.layer.shadowPath = UIBezierPath(roundedRect: selectVw.bounds, cornerRadius: 12).cgPath
    }
    
    private func setupQuantityView() {
        quantityVw.layer.borderColor = UIColor.systemBlue.cgColor
        quantityVw.layer.borderWidth = 1
        quantityVw.layer.cornerRadius = 8
        quantityVw.layer.masksToBounds = true
    }
    
    private func setupRoundedBorderedViews() {
        let borderedViews = [blueVw, redVw, sizeVw, bigVw]
        for view in borderedViews {
            view?.layer.cornerRadius = 8
            view?.layer.borderColor = UIColor.systemBlue.cgColor
            view?.layer.borderWidth = 1
            view?.layer.masksToBounds = true
        }
    }
    
    private func setupSelectView() {
        selectVw.layer.cornerRadius = 12
        selectVw.layer.masksToBounds = false
        selectVw.layer.shadowColor = UIColor.black.cgColor
        selectVw.layer.shadowOpacity = 0.2
        selectVw.layer.shadowOffset = CGSize(width: 0, height: 2)
        selectVw.layer.shadowRadius = 4
        selectVw.layer.shadowPath = UIBezierPath(roundedRect: selectVw.bounds, cornerRadius: 12).cgPath
    }
    
    
}
