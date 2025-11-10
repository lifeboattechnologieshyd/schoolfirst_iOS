//
//  SelectCurriculumVC.swift
//  SchoolFirst
//
//  Created by Lifeboat on 08/11/25.
//

import UIKit

class SelectCurriculumVC: UIViewController {
    
    @IBOutlet weak var paranparaButton: UIButton!
    @IBOutlet weak var oxfordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func onClickParanpara(_ sender: UIButton) {
         let vc = storyboard?.instantiateViewController(identifier: "AssessmentsGradeSelectionVC") as! AssessmentsGradeSelectionVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

