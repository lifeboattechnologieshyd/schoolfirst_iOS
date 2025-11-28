//
//  StartTestVC.swift
//  SchoolFirst
//
//  Created by Lifeboat on 08/11/25.
//

import UIKit

class StartTestVC: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var topVw: UIView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblSubjectName: UILabel!
    @IBOutlet weak var lblQuestions: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var btnStart: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblName.text = UserManager.shared.assessment_created_assessment.name
        lblSubjectName.text = UserManager.shared.assessment_created_assessment.subjectName
        lblDescription.text = "Its a focused test designed to help students practice selected topics, making it easier to understand concepts and apply them with confidence."
        lblQuestions.text = "\(UserManager.shared.assessment_created_assessment.numberOfQuestions) Questions | \(UserManager.shared.assessment_created_assessment.totalMarks) Marks"
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }

    @IBAction func onClickStartButton(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(identifier: "QuestionVC") as? QuestionVC
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
}
