//
//  MychiledattendanceVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 18/08/26.
//

import UIKit
class MychiledattendanceVC: UIViewController {
    
    @IBOutlet weak var Topview: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTopViewShadow()
    }
    private func setupTopViewShadow() {
        Topview.layer.shadowColor = UIColor.lightGray.cgColor
        Topview.layer.shadowOpacity = 0.4
        Topview.layer.shadowOffset = CGSize(width: 0, height: 4)
        Topview.layer.shadowRadius = 2
        Topview.layer.masksToBounds = false
    }
    }
