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
    @IBOutlet weak var lottieView: LottieAnimationView!
    var mobile = ""
    var username = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playLottieFile()
        self.lblUsername.text = "Welcome back \(username)"
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @IBAction func onClickForgotPassword(_ sender: Any) {
        self.forgetPassword()
    }
    
    @IBAction func onClickLogin(_ sender: Any) {
        if self.txtFieldPassword.hasText {
            self.loginWithPassword()
        }else{
            print("Please enter password")
        }
    }
    
    func forgetPassword(){
        let payload : [String:Any] = [
            "mobile": mobile,
            "is_forgot_password": true
        ]
        NetworkManager.shared.request(urlString: API.SENDOTP, method: .POST, parameters: payload) { (result: Result<APIResponse<MobileCheckResponse>, NetworkError>) in
            switch result {
            case .success(let info):
                if info.success {
                    DispatchQueue.main.async {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "OTPViewController") as? OTPViewController
                        vc?.mobile = self.mobile
                        self.navigationController?.pushViewController(vc!, animated: true)
                    }
                }else{
                    self.showAlert(msg: "Login Failed")
                }
                break
            case .failure(_):
                self.showAlert(msg: "School is not associated with the system. Please contact your school admin")
                break
            }
        }
    }
    
    func loginWithPassword(){
        let payload = [
            "mobile": mobile,
            "password": self.txtFieldPassword.text!
        ]
        
        print(payload)
        NetworkManager.shared.request(urlString: API.LOGIN, method: .POST, parameters: payload) { (result: Result<APIResponse<LoginResponse>, NetworkError>) in
            switch result {
            case .success(let info):
                if info.success {
                    print("Login Success")
                    UserDefaults.standard.set(info.data!.accessToken, forKey: "ACCESSTOKEN")
                    UserDefaults.standard.set(info.data!.refreshToken, forKey: "REFRESHTOKEN")
                    UserDefaults.standard.set(true, forKey: "LOGGEDIN")
                    UserManager.shared.saveUser(user: info.data!.user)
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
                }else{
                    self.showAlert(msg: "Login Failed")
                }
                break
            case .failure(_):
                self.showAlert(msg: "School is not associated with the system. Please contact your school admin")
                break
            }
        }
    }
    
    func playLottieFile(){
        let animation = LottieAnimation.named("login.json")
        lottieView.animation = animation
        lottieView.contentMode = .scaleAspectFit
        lottieView.loopMode = .loop
        lottieView.animationSpeed = 1.0
        lottieView.play()
    }
    
}
