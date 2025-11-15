//
//  SchoolFeesVC.swift
//  SchoolFirst
//
//  Created by Lifeboat on 14/11/25.
//

import UIKit

class SchoolFeesVC: UIViewController {
    
    @IBOutlet weak var topVw: UIView!
    @IBOutlet weak var feeVw: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var dueButton: UIButton!
    
    @IBOutlet weak var remainderLbl: UILabel!
    @IBOutlet weak var dueVw: UIView!
    @IBOutlet weak var dueVwHeight: NSLayoutConstraint!
    
    var isDueVisible = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topVw.addBottomShadow()

        
        remainderLbl.numberOfLines = 0
        remainderLbl.lineBreakMode = .byWordWrapping
        
        remainderLbl.text = "Only 2 Days remaining. Pay Now to avoid Fine"
        
        dueVw.isHidden = true
        dueVwHeight.constant = 0
        
        feeVw.layer.masksToBounds = false
        feeVw.addCardShadow()
    }
    
    @IBAction func onClickDue(_ sender: UIButton) {
        toggleDueSection()
    }
    @IBAction func onClickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
   
    
    func toggleDueSection() {
        
        isDueVisible.toggle()
        
        if isDueVisible {
            dueVw.isHidden = false
            dueVwHeight.constant = 50
            
            remainderLbl.text = "Due date passed 2 days ago. Please Pay the Fee immediately to avoid Late Fee Fine of ₹100 per day"
            
        } else {
            dueVwHeight.constant = 0
            dueVw.isHidden = true
            
            remainderLbl.text = "Only 2 Days remaining. Pay Now to avoid Fine"
        }
        
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
}
