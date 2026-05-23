//
//  ComingSoonVC.swift
//  SchoolFirst
//
//  Created by Lifeboat on 18/11/25.
//

import UIKit

class ComingSoonVC: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    
    
    @IBOutlet weak var topVw: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
        @IBAction func backButtonTapped(_ sender: UIButton) {
            self.navigationController?.popViewController(animated: true)
        }

        
        
    }

