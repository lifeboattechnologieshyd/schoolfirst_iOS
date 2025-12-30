//
//  PopUpVC.swift
//  SchoolFirst
//
//  Created by Lifeboat on 27/12/25.
//
import UIKit
import Lottie

class PopUpVC: UIViewController {
    
    var isSuccess: Bool = false
       var message: String = ""
     

    @IBOutlet weak var animationVw: UIView!
    @IBOutlet weak var okBtn: UIButton!
    @IBOutlet weak var descriptionLbl: UILabel!

    private var lottieView: LottieAnimationView?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func configure(isSuccess: Bool, message: String) {

        descriptionLbl.text = message

        let animationName = isSuccess ? "vocabbee_success" : "Payment Failed"

        lottieView?.removeFromSuperview()

        let animation = LottieAnimation.named(animationName)
        let animationView = LottieAnimationView(animation: animation)

        animationView.frame = animationVw.bounds
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce

        animationVw.addSubview(animationView)
        animationView.play()

        self.lottieView = animationView
    }

    @IBAction func onClickOk(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}
