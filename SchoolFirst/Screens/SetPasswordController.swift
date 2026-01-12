//
//  SetPasswordController.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 10/09/25.
//

import UIKit
import Lottie

class SetPasswordController: UIViewController {
    
    @IBOutlet weak var lottieView: LottieAnimationView!
    @IBOutlet weak var txtFieldPassword: UITextField!
    @IBOutlet weak var txtfieldConfirmPassword: UITextField!
    @IBOutlet weak var showbtn: UIButton!
    @IBOutlet weak var show1btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.playLottieFile()
        setupPasswordFields()
    }
    
    func setupPasswordFields() {
        // First textfield - hidden, show "show" image
        txtFieldPassword.isSecureTextEntry = true
        showbtn.setImage(UIImage(named: "show"), for: .normal)
        showbtn.tag = 0  // 👈 0 = password hidden
        
        // Second textfield - hidden, show "show" image
        txtfieldConfirmPassword.isSecureTextEntry = true
        show1btn.setImage(UIImage(named: "show"), for: .normal)
        show1btn.tag = 0  // 👈 0 = password hidden
    }
    
    @IBAction func onClickShowHidePassword(_ sender: UIButton) {
        if sender.tag == 0 {
            sender.tag = 1
            txtFieldPassword.isSecureTextEntry = false
            sender.setImage(UIImage(named: "hide"), for: .normal)
        } else {
            sender.tag = 0
            txtFieldPassword.isSecureTextEntry = true
            sender.setImage(UIImage(named: "show"), for: .normal)
        }
    }
    
    @IBAction func onClickShowHideConfirmPassword(_ sender: UIButton) {
        if sender.tag == 0 {
            sender.tag = 1
            txtfieldConfirmPassword.isSecureTextEntry = false
            sender.setImage(UIImage(named: "hide"), for: .normal)
        } else {
            sender.tag = 0
            txtfieldConfirmPassword.isSecureTextEntry = true
            sender.setImage(UIImage(named: "show"), for: .normal)
        }
    }
    
    @IBAction func onClickBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func playLottieFile() {
        let animation = LottieAnimation.named("login.json")
        lottieView.animation = animation
        lottieView.contentMode = .scaleAspectFit
        lottieView.loopMode = .loop
        lottieView.animationSpeed = 1.0
        lottieView.play()
    }
    
    @IBAction func onClickSubmit(_ sender: UIButton) {
        let error = PasswordValidator.validate(password: txtFieldPassword.text ?? "", confirmPassword: txtfieldConfirmPassword.text ?? "")
        if let error = error {
            print("❌ \(error)")
        } else {
            print("✅ Password valid")
            loginWithPassword()
        }
    }
    
    func loginWithPassword() {
        let payload = [
            "password": txtFieldPassword.text!
        ]
        
        NetworkManager.shared.request(urlString: API.SET_PASSWORD, method: .POST, parameters: payload) { (result: Result<APIResponse<EmptyResponse>, NetworkError>) in
            switch result {
            case .success(let info):
                if info.success {
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
                    self.showAlert(msg: "Login Failed")
                }
            case .failure(_):
                self.showAlert(msg: "School is not associated with the system. Please contact your school admin")
            }
        }
    }
}
