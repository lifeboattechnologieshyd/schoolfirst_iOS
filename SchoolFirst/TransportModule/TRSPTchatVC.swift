//
//  TRSPTchatVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 30/07/26.
//

import UIKit
class TRSPTchatVC: UIViewController {
    
    @IBOutlet weak var BackButton: UIButton!
    @IBOutlet weak var TopView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTopViewShadow()
    }
    
    @IBAction func BackButtonTapped(_ sender: UIButton) {

        // If Homescreen was pushed from EdutainmentVC
        navigationController?.popViewController(animated: true)

    }
    
    private func setupTopViewShadow() {

        TopView.layer.shadowColor =
        UIColor.lightGray.cgColor

        TopView.layer.shadowOpacity = 0.4

        TopView.layer.shadowOffset =
        CGSize(width: 0, height: 4)

        TopView.layer.shadowRadius = 2

        TopView.layer.masksToBounds = false
    }

    }
