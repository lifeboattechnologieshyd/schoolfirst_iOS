//
//  DailyChallengeViewController.swift
//  SchoolFirst
//
//  Created by Lifeboat on 22/10/25.
//

import  UIKit

class DailyChallengeViewController:UIViewController{
    
    
    @IBOutlet weak var exitButton: UIButton!
    
    @IBAction func exitButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }
}
