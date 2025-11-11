//
//  PastAssessmentsVC.swift
//  SchoolFirst
//
//  Created by Lifeboat on 10/11/25.
//

import UIKit

class PastAssessmentsVC: UIViewController {
    
    @IBOutlet weak var secondVw: UIView!
    @IBOutlet weak var seeVw: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBorders()
    }
    
    private func setupBorders() {
        let borderColor = UIColor(red: 0.80, green: 0.90, blue: 0.99, alpha: 1).cgColor  // #CBE5FD
        
        [secondVw, seeVw].forEach {
            $0?.layer.borderColor = borderColor
            $0?.layer.borderWidth = 1
             $0?.clipsToBounds = true
        }
    }
}

