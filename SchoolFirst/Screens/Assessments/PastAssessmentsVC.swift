//
//  PastAssessmentsVC.swift
//  SchoolFirst
//
//  Created by Lifeboat on 10/11/25.
//

import UIKit

class PastAssessmentsVC: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var ResultButton: UIButton!
    @IBOutlet weak var resultsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func onResultButtonTap(_ sender: UIButton) {
        navigateToAllQuestions()
    }
    
    @IBAction func onResultsButtonTap(_ sender: UIButton) {
        navigateToAllQuestions()
    }
    
    private func navigateToAllQuestions() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "AllQuestionsVC") as! AllQuestionsVC
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "AssessmentsViewController") as! AssessmentsViewController
        navigationController?.pushViewController(vc, animated: true)
    }
}
