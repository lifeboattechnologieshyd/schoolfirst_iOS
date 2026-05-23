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
        playLottieFile()
        setupLabel()
        txtFieldOTP.font = UIFont.lexend(.regular, size: 24)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @IBAction func onClickBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func playLottieFile() {
        let animation = LottieAnimation.named("otp_sf.json")
        imgVw.animation = animation
        imgVw.contentMode = .scaleAspectFit
        imgVw.loopMode = .loop
        imgVw.animationSpeed = 1.0
        imgVw.play()
    }
    
    @IBAction func onClickSubmit(_ sender: UIButton) {
        if txtFieldOTP.hasText && txtFieldOTP.text?.count == 4 {
            if mobile.isValidEmail {
                self.verifyOtpwithEmail()
            } else {
                verifyOtp()
            }
        } else {
            self.showAlert(msg: "Please enter Valid OTP")
        }
    }
    
    func setupLabel() {
        var message = "A 4 Digit OTP has been sent to +91 \(mobile)"
        var boldParts = ["4 Digit OTP", "+91 \(mobile)"]

        if mobile.isValidEmail {
            message = "A 4 Digit OTP has been sent to \(mobile)"
            boldParts = ["4 Digit OTP", "\(mobile)"]
        }
        
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
    
    func verifyOtpwithEmail() {
        let payload = [
            "email": mobile,
            "otp": self.txtFieldOTP.text!,
            "device_id": "",
            "fcm_id": "",
            "device_os": "iOS"
        ]
        showLoader()
        
        NetworkManager.shared.request(urlString: API.EMAIL_OTP,method: .POST, is_testing: true, parameters: payload) { (result: Result<APIResponse<LoginResponse>, NetworkError>) in
            self.hideLoader()
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
                } else {
                    self.showAlert(msg: info.description)
                }
            case .failure(_):
                self.showAlert(msg: "Oops")
            }
        }
    }
    
    func verifyOtp() {
        let payload = [
            "mobile": mobile,
            "otp": self.txtFieldOTP.text!
        ]
        showLoader()
        
        NetworkManager.shared.request(urlString: API.VERIFY_OTP, method: .POST, parameters: payload) { (result: Result<APIResponse<LoginResponse>, NetworkError>) in
            self.hideLoader()
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
                } else {
                    self.showAlert(msg: info.description)
                }
            case .failure(_):
                self.showAlert(msg: "Oops")
            }
        }
    }
}
