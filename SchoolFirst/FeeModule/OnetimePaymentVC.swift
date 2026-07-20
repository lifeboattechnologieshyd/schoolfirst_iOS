//
//  OnetimePaymentVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 22/06/26.
//

import UIKit
class OnetimePaymentVC: UIViewController {
    
    @IBOutlet weak var BackButton: UIButton!
    @IBOutlet weak var TopView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTopViewShadow()
    }
    private func setupTopViewShadow() {

        TopView.layer.shadowColor = UIColor.lightGray.cgColor
        TopView.layer.shadowOpacity = 0.4
        TopView.layer.shadowOffset = CGSize(width: 0, height: 4)
        TopView.layer.shadowRadius = 2
        TopView.layer.masksToBounds = false
    }
    @IBAction func BackButtonTapped(_ sender: UIButton) {

        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    }
