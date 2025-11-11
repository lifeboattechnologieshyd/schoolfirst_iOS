//
//  StartTestVC.swift
//  SchoolFirst
//
//  Created by Lifeboat on 08/11/25.
//

import UIKit

class StartTestVC: UIViewController {
    
    @IBOutlet weak var topVw: UIView!
    @IBOutlet weak var starttestButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    @IBAction func onClickStartTest(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(identifier: "AllQuestionsVC") as? AllQuestionsVC
        self.navigationController?.pushViewController(vc!, animated: true)
    }
  
}
