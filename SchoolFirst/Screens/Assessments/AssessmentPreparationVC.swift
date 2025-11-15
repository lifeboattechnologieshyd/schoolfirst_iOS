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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.goToStartTestVC()
        }
    }
    
    
    func createAssessment() {
        let subject_url = API.ASSESSMENT_CREATE
        NetworkManager.shared.request(urlString: subject_url,method: .GET) { (result: Result<APIResponse<[GradeSubject]>, NetworkError>)  in
            switch result {
            case .success(let info):
                if info.success {
                    if let data = info.data {
                        DispatchQueue.main.async {
//                            self.colVw.reloadData()
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
