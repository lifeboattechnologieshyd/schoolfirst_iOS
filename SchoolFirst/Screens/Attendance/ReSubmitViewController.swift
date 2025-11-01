//
//  ReSubmitViewController.swift
//  SchoolFirst
//
//  Created by Lifeboat on 01/11/25.
//

import UIKit

class ReSubmitViewController: UIViewController {
    
    @IBOutlet weak var topVw: UIView!
    @IBOutlet weak var leaveVw: UIView!
    @IBOutlet weak var reasonsButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var bottomVw: UIView!
    @IBOutlet weak var rejectedVw: UIView!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var submitVw: UIView!
    @IBOutlet weak var reasonVw: UIView!
    @IBOutlet weak var abhiVw: UIView!
    @IBOutlet weak var detailTf: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topVw.addBottomShadow()

        
        setupUI()
    }
    
    private func setupUI() {
        abhiVw.layer.cornerRadius = 25
        abhiVw.layer.borderWidth = 1
        abhiVw.layer.borderColor = UIColor(red: 11/255, green: 86/255, blue: 154/255, alpha: 1).cgColor
        
        
        rejectedVw.layer.cornerRadius = 12

        leaveVw.layer.cornerRadius = 10
        leaveVw.layer.shadowColor = UIColor.black.cgColor
        leaveVw.layer.shadowOpacity = 0.2
        leaveVw.layer.shadowOffset = CGSize(width: 0, height: 2)
        leaveVw.layer.shadowRadius = 4
        leaveVw.layer.masksToBounds = false
        
        reasonVw.layer.cornerRadius = 5
        reasonVw.layer.shadowColor = UIColor.black.cgColor
        reasonVw.layer.shadowOpacity = 0.2
        reasonVw.layer.shadowOffset = CGSize(width: 0, height: 2)
        reasonVw.layer.shadowRadius = 4
        reasonVw.layer.masksToBounds = false
        
                detailTf.layer.cornerRadius = 5
                detailTf.layer.shadowColor = UIColor.black.cgColor
                detailTf.layer.shadowOpacity = 0.2
                detailTf.layer.shadowOffset = CGSize(width: 0, height: 2)
                detailTf.layer.shadowRadius = 4
                detailTf.layer.masksToBounds = false
               
        
         
        addDashedBorder(to: submitVw, color: UIColor(red: 157/255, green: 168/255, blue: 181/255, alpha: 1), lineWidth: 1, dashPattern: [5, 5])
        submitVw.layer.cornerRadius = 8
        submitVw.layer.masksToBounds = true
        
         bottomVw.layer.shadowColor = UIColor.black.cgColor
        bottomVw.layer.shadowOpacity = 0.15
        bottomVw.layer.shadowOffset = CGSize(width: 0, height: -2) // Top shadow only
        bottomVw.layer.shadowRadius = 4
        bottomVw.layer.masksToBounds = false
    }
    
     private func addDashedBorder(to view: UIView, color: UIColor, lineWidth: CGFloat, dashPattern: [NSNumber]) {
        let dashedBorder = CAShapeLayer()
        dashedBorder.strokeColor = color.cgColor
        dashedBorder.lineDashPattern = dashPattern
        dashedBorder.lineWidth = lineWidth
        dashedBorder.fillColor = nil
        dashedBorder.path = UIBezierPath(roundedRect: view.bounds, cornerRadius: view.layer.cornerRadius).cgPath
        dashedBorder.frame = view.bounds
        view.layer.addSublayer(dashedBorder)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
         submitVw.layer.sublayers?.forEach { if $0 is CAShapeLayer { $0.removeFromSuperlayer() } }
        addDashedBorder(to: submitVw, color: UIColor(red: 157/255, green: 168/255, blue: 181/255, alpha: 1), lineWidth: 1, dashPattern: [5, 5])
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

