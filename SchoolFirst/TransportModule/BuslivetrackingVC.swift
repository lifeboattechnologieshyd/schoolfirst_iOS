//
//  BuslivetrackingVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 31/07/26.
//

import UIKit
class BuslivetrackingVC: UIViewController {
    
    @IBOutlet weak var BackButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    @IBAction func BackButtonTapped(_ sender: UIButton) {

        // If Homescreen was pushed from EdutainmentVC
        navigationController?.popViewController(animated: true)

    }
    
    
    }
