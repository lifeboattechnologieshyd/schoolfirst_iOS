//
//  MarkedcompletedVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 18/08/26.
//

import UIKit
class MarkedcompletedVC: UIViewController {
    
    @IBOutlet weak var Homeworktitlewithpdf: UILabel!
    @IBOutlet weak var Homeworktitle: UILabel!
    @IBOutlet weak var Subject: UILabel!
    
    @IBOutlet weak var Description: UILabel!
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
    }
