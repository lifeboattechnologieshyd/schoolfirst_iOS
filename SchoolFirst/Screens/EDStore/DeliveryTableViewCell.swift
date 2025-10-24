//
//  DeliveryTableViewCell.swift
//  SchoolFirst
//
//  Created by Lifeboat on 23/10/25.
//

import UIKit

class DeliveryTableViewCell: UITableViewCell {

    @IBOutlet weak var changeVw: UIView!
    @IBOutlet weak var changeLbl: UILabel!
    @IBOutlet weak var deliveryLbl: UILabel!
    @IBOutlet weak var mainVw: UIView!
    @IBOutlet weak var homeImg: UIImageView!
    @IBOutlet weak var businessLbl: UILabel!
    @IBOutlet weak var businessTf: UITextField!
    @IBOutlet weak var cityLbl: UILabel!
    @IBOutlet weak var cityTf: UITextField!
    @IBOutlet weak var phoneTf: UITextField!
    @IBOutlet weak var saveAddressLbl: UILabel!
    @IBOutlet weak var greencheckbox: UIButton!
    @IBOutlet weak var phoneLbl: UILabel!
    @IBOutlet weak var pincodeTf: UITextField!
    @IBOutlet weak var pincodeLbl: UILabel!
    @IBOutlet weak var stateTf: UITextField!
    @IBOutlet weak var stateLbl: UILabel!
    @IBOutlet weak var nameTf: UITextField!
    @IBOutlet weak var nameLbl: UILabel!
    

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let textFields = [businessTf, cityTf, phoneTf, pincodeTf, stateTf, nameTf]
               for tf in textFields {
                   tf?.layer.cornerRadius = 8
                   tf?.layer.masksToBounds = false
                   tf?.layer.shadowColor = UIColor.black.cgColor
                   tf?.layer.shadowOpacity = 0.15
                   tf?.layer.shadowOffset = CGSize(width: 0, height: 2)
                   tf?.layer.shadowRadius = 4
                   tf?.backgroundColor = .white
                   tf?.layer.borderWidth = 0
               }
               
                changeVw.layer.cornerRadius = 8
                changeVw.layer.borderColor = UIColor.systemBlue.cgColor
                changeVw.layer.borderWidth = 1.5
                changeVw.layer.masksToBounds = true
               
                mainVw.layer.cornerRadius = 10
                mainVw.layer.borderColor = UIColor.systemGreen.cgColor
                mainVw.layer.borderWidth = 2
                mainVw.layer.masksToBounds = true
           }

           override func setSelected(_ selected: Bool, animated: Bool) {
               super.setSelected(selected, animated: animated)
           }
       }
