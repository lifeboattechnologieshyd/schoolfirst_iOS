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
        
        print( UserManager.shared.assessment_selected_grade.id)
        print( UserManager.shared.assessment_selected_subject.id)
        print( UserManager.shared.assessmentSelectedStudent.studentID)

        print( UserManager.shared.assessment_selected_lesson_ids.first!)
        
        
        
        let payload: [String:Any] = [
            "grade_id": UserManager.shared.assessment_selected_grade.id,
            "subject_id":UserManager.shared.assessment_selected_subject.id,
            "lesson_ids":UserManager.shared.assessment_selected_lesson_ids,
            "student_id":UserManager.shared.assessmentSelectedStudent.studentID
        ]
        print(payload)
        
        let subject_url = API.ASSESSMENT_CREATE
        NetworkManager.shared.request(urlString: subject_url,method: .POST, parameters: payload) { (result: Result<APIResponse<[Assessment]>, NetworkError>)  in
            switch result {
            case .success(let info):
                if info.success {
                    if let data = info.data {
                        DispatchQueue.main.async {
                            if data.count > 0 {
                                UserManager.shared.assessment_created_assessment = data[0]
                                self.goToStartTestVC()
                            }
                        }
                    }
                }else{
                    print(info.description)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    switch error {
                    case .noaccess:
                        self.handleLogout()
                    default:
                        self.showAlert(msg: error.localizedDescription)
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
    func playLottieFile(){
        let animation = LottieAnimation.named("loading.json")
        imgVw.animation = animation
        imgVw.contentMode = .scaleAspectFit
        imgVw.loopMode = .loop
        imgVw.animationSpeed = 1.0
        imgVw.play()
    }
    
    // api call to generate/get assessment. then display start quiz popup.
    
    
    func goToStartTestVC(){
        let vc = storyboard?.instantiateViewController(identifier: "StartTestVC") as? StartTestVC
        self.navigationController?.pushViewController(vc!, animated: true)
    }

}
