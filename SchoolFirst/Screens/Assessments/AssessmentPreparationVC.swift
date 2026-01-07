//
//  AssessmentPreparationVC.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 11/10/25.
//

import UIKit
import Lottie

class AssessmentPreparationVC: UIViewController {
    
    @IBOutlet weak var imgVw: LottieAnimationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playLottieFile()
        createAssessment()
    }
    
    func createAssessment() {
        guard !UserManager.shared.assessment_selected_lesson_ids.isEmpty else {
            showAlert(msg: "Please select at least one lesson")
            navigationController?.popViewController(animated: true)
            return
        }
        
        guard let grade = UserManager.shared.assessment_selected_grade,
              let subject = UserManager.shared.assessment_selected_subject,
              let student = UserManager.shared.assessmentSelectedStudent else {
            
            
            showAlert(msg: "Missing required assessment data. Please try again.")
            navigationController?.popViewController(animated: true)
            return
        }
        
        let payload: [String: Any] = [
            "grade_id": grade.id,
            "subject_id": subject.id,
            "lesson_ids": UserManager.shared.assessment_selected_lesson_ids,
            "student_id": student.studentID
        ]
        
        
        NetworkManager.shared.request(urlString: API.ASSESSMENT_CREATE, method: .POST, parameters: payload) { [weak self] (result: Result<APIResponse<[Assessment]>, NetworkError>) in
            
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let info):
                    if info.success, let data = info.data, let assessment = data.first {
                        UserManager.shared.assessment_created_assessment = assessment
                        self.goToStartTestVC()
                    } else {
                        self.showAlert(msg: info.description)
                        self.navigationController?.popViewController(animated: true)
                    }
                    
                case .failure(let error):
                    if case .noaccess = error {
                        self.handleLogout()
                    } else {
                        self.showAlert(msg: error.localizedDescription)
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
    func playLottieFile() {
        guard let animationView = imgVw else { return }
        
        guard let animation = LottieAnimation.named("loading") else {
            return
        }
        
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.animationSpeed = 1.0
        animationView.play()
    }
    
    func goToStartTestVC() {
        guard let vc = storyboard?.instantiateViewController(identifier: "StartTestVC") as? StartTestVC else {
            return
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}
