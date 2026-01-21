//
//  LoginController.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 29/06/25.
//

import UIKit
import Lottie

class LoginController: UIViewController {
    
    @IBOutlet weak var txtFieldPassword: UITextField!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var showbtn: UIButton!
    @IBOutlet weak var lottieView: LottieAnimationView!
    var mobile = ""
    var username = ""
    var isPasswordVisible = false
    var isMobileLogin = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playLottieFile()
        self.lblUsername.text = "Welcome back \(username)"
    
    setupPasswordField()
        }
    func setupPasswordField() {
           txtFieldPassword.isSecureTextEntry = true
           showbtn.setImage(UIImage(named: "view"), for: .normal)
       }
       
       @IBAction func onClickShowHidePassword(_ sender: UIButton) {
           isPasswordVisible.toggle()
           
           if isPasswordVisible {
               // Show password
               txtFieldPassword.isSecureTextEntry = false
               showbtn.setImage(UIImage(named: "hide"), for: .normal)
           } else {
               // Hide password
               txtFieldPassword.isSecureTextEntry = true
               showbtn.setImage(UIImage(named: "view"), for: .normal)
           }
       }
       
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    @IBAction func onClickForgotPassword(_ sender: Any) {
        self.forgetPassword()
    }
    
    @IBAction func onClickLogin(_ sender: Any) {
        if self.txtFieldPassword.hasText {
            self.loginWithPassword()
        } else {
            print("Please enter password")
        }
    }
    
    func forgetPassword() {
        
        var payload: [String: Any] = [
            "is_forgot_password": true
        ]
        var ur = API.SENDOTP
        if !isMobileLogin {
            payload["email"] = mobile
            ur = API.EMAIL_SENDOTP
        }else {
            payload["mobile"] = mobile

        }
        
        NetworkManager.shared.request(urlString: ur, method: .POST, parameters: payload) { (result: Result<APIResponse<MobileCheckResponse>, NetworkError>) in
            switch result {
            case .success(let info):
                if info.success {
                    DispatchQueue.main.async {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "OTPViewController") as? OTPViewController
                        vc?.mobile = self.mobile
                        self.navigationController?.pushViewController(vc!, animated: true)
                    }
                } else {
                    self.showAlert(msg: "Login Failed")
                }
            case .failure(_):
                self.showAlert(msg: "School is not associated with the system. Please contact your school admin")
            }
        }
    }
    
    func loginWithPassword() {
        var payload = [
            "password": self.txtFieldPassword.text!
        ]
        if isMobileLogin {
            payload["mobile"] = mobile
        }else {
            payload["email"] = mobile
        }
      
        
        
        print(payload)
        NetworkManager.shared.request(urlString: API.LOGIN, method: .POST, parameters: payload) { (result: Result<APIResponse<LoginResponse>, NetworkError>) in
            switch result {
            case .success(let info):
                if info.success, let data = info.data {
                    print("Login Success")
                    UserDefaults.standard.set(data.accessToken, forKey: "ACCESSTOKEN")
                    UserDefaults.standard.set(data.refreshToken, forKey: "REFRESHTOKEN")
                    UserDefaults.standard.set(true, forKey: "LOGGEDIN")
                    UserManager.shared.saveUser(user: data.user)
                    
                    DispatchQueue.main.async {
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
                    DispatchQueue.main.async {
                        self.showAlert(msg: "Invalid Credentials")
                    }
                }
            case .failure(_):
                DispatchQueue.main.async {
                    self.showAlert(msg: "School is not associated with the system. Please contact your school admin")
                }
            }
        }
    }
    
    func playLottieFile() {
        let animation = LottieAnimation.named("login.json")
        lottieView.animation = animation
        lottieView.contentMode = .scaleAspectFit
        lottieView.loopMode = .loop
        lottieView.animationSpeed = 1.0
        lottieView.play()
    }
}
