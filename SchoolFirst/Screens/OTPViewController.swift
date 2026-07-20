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
    var simulatorOTP: String? = nil  // Set by caller on simulator builds

    override func viewDidLoad() {
        super.viewDidLoad()
        playLottieFile()
        setupLabel()
        txtFieldOTP.font = UIFont.lexend(.regular, size: 24)

        // ── Simulator-only: auto-fill OTP if backend returned it ──
        #if targetEnvironment(simulator)
        if let otp = simulatorOTP, !otp.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.txtFieldOTP.text = otp
                let alert = UIAlertController(
                    title: "🖥️ Simulator OTP",
                    message: "OTP \(otp) has been auto-filled.\n(Only visible on Simulator)",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        } else {
            // Backend didn't return OTP in response — show manual hint
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let alert = UIAlertController(
                    title: "🖥️ Simulator — OTP Help",
                    message: "Simulators can't receive SMS.\nCheck Xcode console or ask backend team for the OTP.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
        #endif
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
        let fcmToken = UserDefaults.standard.string(forKey: "FCMToken") ?? ""
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? ""
        let payload: [String: Any] = [
            "email": mobile,
            "otp": self.txtFieldOTP.text!,
            "device_id": deviceId,
            "fcm_id": fcmToken,
            "device_type": "iOS",
            "device_os": "iOS"
        ]
        showLoader()
        
        NetworkManager.shared.request(urlString: API.EMAIL_OTP,method: .POST, is_testing: false, requiresAuth: false, parameters: payload) { (result: Result<APIResponse<VerifyOTPResponse>, NetworkError>) in
            self.hideLoader()
            switch result {
            case .success(let info):
                if info.success {
                    DispatchQueue.main.async {
                        UserDefaults.standard.set(info.data!.access, forKey: "ACCESSTOKEN")
                        UserDefaults.standard.set(info.data!.refresh, forKey: "REFRESHTOKEN")
                        UserDefaults.standard.set(true, forKey: "LOGGEDIN")
                        
                        let dummyUser = User(
                            id: info.data!.userId,
                            firstName: nil,
                            lastName: nil,
                            schoolIDs: info.data?.schoolId != nil ? [info.data!.schoolId!] : [],
                            username: self.mobile,
                            profileImage: nil,
                            email: nil,
                            referralCode: "",
                            mobile: Int64(self.mobile),
                            deviceID: nil,
                            students: info.data!.students
                        )
                        UserManager.shared.saveUser(user: dummyUser)
                        
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        if let tabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? MainTabBarController {
                            tabBarController.selectedIndex = 2
                            
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let window = windowScene.windows.first {
                                window.rootViewController = tabBarController
                                window.makeKeyAndVisible()
                            }
                        }
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
        let fcmToken = UserDefaults.standard.string(forKey: "FCMToken") ?? ""
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? ""
        let payload: [String: Any] = [
            "mobile": mobile,
            "otp": self.txtFieldOTP.text!,
            "device_id": deviceId,
            "fcm_id": fcmToken,
            "device_type": "iOS",
            "device_os": "iOS"
        ]
        showLoader()
        
        NetworkManager.shared.request(urlString: API.VERIFY_OTP, method: .POST, requiresAuth: false, parameters: payload) { (result: Result<APIResponse<VerifyOTPResponse>, NetworkError>) in
            self.hideLoader()
            switch result {
            case .success(let info):
                if info.success {
                    DispatchQueue.main.async {
                        UserDefaults.standard.set(info.data!.access, forKey: "ACCESSTOKEN")
                        UserDefaults.standard.set(info.data!.refresh, forKey: "REFRESHTOKEN")
                        UserDefaults.standard.set(true, forKey: "LOGGEDIN")
                        
                        let dummyUser = User(
                            id: info.data!.userId,
                            firstName: nil,
                            lastName: nil,
                            schoolIDs: [],
                            username: self.mobile,
                            profileImage: nil,
                            email: nil,
                            referralCode: "",
                            mobile: Int64(self.mobile),
                            deviceID: nil,
                            students: info.data!.students
                        )
                        UserManager.shared.saveUser(user: dummyUser)
                        
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        if let tabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? MainTabBarController {
                            tabBarController.selectedIndex = 2
                            
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let window = windowScene.windows.first {
                                window.rootViewController = tabBarController
                                window.makeKeyAndVisible()
                            }
                        }
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
