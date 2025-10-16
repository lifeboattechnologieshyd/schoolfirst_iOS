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
    
    
    func playLottieFile(){
        let animation = LottieAnimation.named("loading.json")
        imgVw.animation = animation
        imgVw.contentMode = .scaleAspectFit
        imgVw.loopMode = .loop
        imgVw.animationSpeed = 1.0
        imgVw.play()
    }

}
