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
