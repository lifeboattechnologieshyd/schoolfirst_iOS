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
    @IBOutlet weak var topLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    
    private var lottieView: LottieAnimationView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    private func configureUI() {
        if isSuccess {
            // Success State
            topLbl.text = "Hurray!"
            descriptionLbl.text = "Thank you! Your payment has been processed successfully."
            playLottieAnimation(named: "success")
        } else {
            // Failure State
            topLbl.text = "Oops!"
            descriptionLbl.text = "Your payment couldn't be processed. Please try again later."
            playLottieAnimation(named: "Failure")
        }
        
        if !message.isEmpty {
            descriptionLbl.text = message
        }
        
        // Style the OK button
        okBtn.layer.cornerRadius = 8
        okBtn.setTitleColor(.white, for: .normal)
    }
    
    private func playLottieAnimation(named animationName: String) {
        // Remove existing animation if any
        lottieView?.removeFromSuperview()
        
        // Create new animation view
        guard let animation = LottieAnimation.named(animationName) else {
            print("Could not find animation: \(animationName)")
            return
        }
        
        let animationView = LottieAnimationView(animation: animation)
        animationView.frame = animationVw.bounds
        animationView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        
        animationVw.addSubview(animationView)
        animationView.play()
        
        self.lottieView = animationView
    }
    
    @IBAction func onClickOk(_ sender: UIButton) {
        self.dismiss(animated: true) {
            // If success, you might want to navigate back or to orders page
            if self.isSuccess {
                // Post notification to refresh or navigate
                NotificationCenter.default.post(name: NSNotification.Name("PaymentSuccess"), object: nil)
            }
        }
    }
}
