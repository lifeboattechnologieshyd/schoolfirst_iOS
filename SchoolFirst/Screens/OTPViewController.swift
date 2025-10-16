//
//  OTPViewController.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 09/09/25.
//

import UIKit
import Lottie

class OTPViewController: UIViewController {
    @IBOutlet weak var imgVw: LottieAnimationView!
    @IBOutlet weak var txtFieldOTP: UITextField!
    @IBOutlet weak var lblMobile: UILabel!
    var mobile = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        playLottieFile()
        setupLabel()
        txtFieldOTP.font = UIFont.lexend(.regular, size: 24)
    }
    
    @IBAction func onClickBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func playLottieFile(){
        let animation = LottieAnimation.named("otp_sf.json")
        imgVw.animation = animation
        imgVw.contentMode = .scaleAspectFit
        imgVw.loopMode = .loop
        imgVw.animationSpeed = 1.0
        imgVw.play()
    }
    @IBAction func onClickSubmit(_ sender: UIButton) {
        if txtFieldOTP.hasText && txtFieldOTP.text?.count == 4 {
            verifyOtp()
        }else {
            self.showAlert(msg: "Please enter Valid OTP")
        }
    }
    
    func setupLabel() {
        let message = "A 4 Digit OTP has been sent to +91 \(mobile)"
        let boldParts = ["4 Digit OTP", "+91 \(mobile)"]
        let attributedString = NSMutableAttributedString(
            string: message,
            attributes: [
                .font: UIFont.lexend(.regular, size: 16)
            ]
        )
        for part in boldParts {
            if let range = message.range(of: part) {
                let nsRange = NSRange(range, in: message)
                attributedString.addAttributes([
                    .font: UIFont.lexend(.semiBold, size: 16)
                ], range: nsRange)
            }
        }
        lblMobile.attributedText = attributedString
    }
    
    func verifyOtp(){
        let payload = [
            "mobile": mobile,
            "otp": self.txtFieldOTP.text!
        ]
        
        NetworkManager.shared.request(urlString: API.VERIFY_OTP, method: .POST, parameters: payload) { (result: Result<APIResponse<LoginResponse>, NetworkError>) in
            switch result {
            case .success(let info):
                if info.success {
                    DispatchQueue.main.async {
                        UserDefaults.standard.set(info.data!.accessToken, forKey: "ACCESSTOKEN")
                        UserDefaults.standard.set(info.data!.refreshToken, forKey: "REFRESHTOKEN")
                        UserDefaults.standard.set(true, forKey: "LOGGEDIN")
                        UserManager.shared.saveUser(user: info.data!.user)
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SetPasswordController") as? SetPasswordController
                        self.navigationController?.pushViewController(vc!, animated: true)
                    }
                }else{
                    self.showAlert(msg: "Login Failed")
                }
                break
            case .failure(_):
                self.showAlert(msg: "Oops")
                break
            }
        }
    }
}
