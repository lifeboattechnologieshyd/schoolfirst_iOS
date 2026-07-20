//
//  ViewController.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 13/06/25.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var imgMobile: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtFieldMobile: UITextField!
    @IBOutlet weak var lblPrivacy: UILabel!
    @IBOutlet weak var btnLogin: UIButton!
    
    @IBOutlet weak var btnMobile: UIButton!
    
    @IBOutlet weak var btnEmail: UIButton!
    
    
    var is_mobile_login = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setText()
        btnMobile.layer.borderWidth = 1
        btnEmail.layer.borderWidth = 1
        
        btnMobile.layer.cornerRadius = 8
        btnEmail.layer.cornerRadius = 8
        
        
        setMobileLogin()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func setText() {
        let attributedString = NSMutableAttributedString(string: "One App! Every School! \n Total Transformation!", attributes: [NSAttributedString.Key.font: UIFont.lexend(.semiBold, size: 24)])
        self.lblTitle.attributedText = attributedString
        self.txtFieldMobile.placeholder = "Enter Mobile Number"
        self.txtFieldMobile.font = UIFont.lexend(.regular, size: 16)
    }
    
    @IBAction func onClickLogin(_ sender: UIButton) {
        if self.is_mobile_login {
            if self.txtFieldMobile.text!.isValidIndianMobile(){
                self.getUserDetails(mobile: self.txtFieldMobile.text!)
            }
            else{
                self.showAlert(msg: "please enter valid mobile number")
            }
        }else {
            if self.txtFieldMobile.text!.isValidEmail {
                self.getUserDetails(email: self.txtFieldMobile.text!)
            }else{
                self.showAlert(msg: "please enter valid mobile number")
            }
        }
    }
    
    @IBAction func onClickMobile(_ sender: UIButton) {
        setMobileLogin()
    }
    @IBAction func onClickEmail(_ sender: UIButton) {
        setEmailLogin()
    }
    
    
    func setMobileLogin(){
        btnMobile.setTitleColor(.primary, for: .normal)
        btnMobile.layer.borderColor = UIColor.primary.cgColor
        btnEmail.setTitleColor(.black, for: .normal)
        btnEmail.layer.borderColor = UIColor(hex: "#CBE5FD")?.cgColor
        txtFieldMobile.keyboardType = .numberPad
        txtFieldMobile.resignFirstResponder()
        imgMobile.image = UIImage(named: "india")
        is_mobile_login = true
        txtFieldMobile.placeholder = "Enter mobile number"
    }
    
    func setEmailLogin(){
        btnEmail.setTitleColor(.primary, for: .normal)
        btnEmail.layer.borderColor = UIColor.primary.cgColor
        btnMobile.setTitleColor(.black, for: .normal)
        btnMobile.layer.borderColor = UIColor(hex: "#CBE5FD")?.cgColor
        txtFieldMobile.keyboardType = .emailAddress
        txtFieldMobile.resignFirstResponder()
        imgMobile.image = UIImage(named: "email")
        is_mobile_login = false
        txtFieldMobile.placeholder = "Enter Email Address"
    }
    
    func getUserDetails(email: String) {
        showLoader()
        let fcmToken = UserDefaults.standard.string(forKey: "FCMToken") ?? ""
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? ""
        let payload: [String: Any] = [
            "email": email,
            "fcm_id": fcmToken,
            "device_id": deviceId,
            "device_type": "iOS"
        ]
        NetworkManager.shared.request(urlString: API.EMAIL_SENDOTP, method: .POST, requiresAuth: false, parameters: payload) { (result: Result<APIResponse<MobileCheckResponse>, NetworkError>) in
            self.hideLoader()
            switch result {
            case .success(let info):
                print("📩 Send OTP (Email) Response → success: \(info.success), description: \(info.description)")
                if let otp = info.data?.otp {
                    print("🔑 [SIMULATOR DEBUG] OTP = \(otp)")
                }
                if info.success {
                    DispatchQueue.main.async {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "OTPViewController") as? OTPViewController
                        vc?.mobile = self.txtFieldMobile.text!
                        #if targetEnvironment(simulator)
                        vc?.simulatorOTP = info.data?.otp
                        #endif
                        self.navigationController?.pushViewController(vc!, animated: true)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showAlert(msg: info.description.isEmpty ? "Failed to send OTP. Please try again." : info.description)
                    }
                }
                break
            case .failure(let error):
                print("❌ Send OTP (Email) Network Error: \(error)")
                DispatchQueue.main.async {
                    switch error {
                    case .serverError(let msg):
                        self.showAlert(msg: "Server error: \(msg)")
                    case .noInternet:
                        self.showAlert(msg: "No internet connection.")
                    default:
                        self.showAlert(msg: "Failed to send OTP. Please check your connection and try again.")
                    }
                }
                break
            }
        }
        
    }
    
    func getUserDetails(mobile: String) {
        let fcmToken = UserDefaults.standard.string(forKey: "FCMToken") ?? ""
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? ""
        let payload: [String: Any] = [
            "mobile": mobile,
            "fcm_id": fcmToken,
            "device_id": deviceId,
            "device_type": "iOS"
        ]
        showLoader()
        NetworkManager.shared.request(urlString: API.SENDOTP, method: .POST, requiresAuth: false, parameters: payload) { (result: Result<APIResponse<MobileCheckResponse>, NetworkError>) in
            self.hideLoader()
            switch result {
            case .success(let info):
                print("📩 Send OTP (Mobile) Response → success: \(info.success), description: \(info.description)")
                if let otp = info.data?.otp {
                    print("🔑 [SIMULATOR DEBUG] OTP = \(otp)")
                }
                if info.success {
                    DispatchQueue.main.async {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "OTPViewController") as? OTPViewController
                        vc?.mobile = self.txtFieldMobile.text!
                        #if targetEnvironment(simulator)
                        vc?.simulatorOTP = info.data?.otp
                        #endif
                        self.navigationController?.pushViewController(vc!, animated: true)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showAlert(msg: info.description.isEmpty ? "Mobile number not registered. Please contact your school admin." : info.description)
                    }
                }
                break
            case .failure(let error):
                print("❌ Send OTP (Mobile) Network Error: \(error)")
                DispatchQueue.main.async {
                    switch error {
                    case .serverError(let msg):
                        self.showAlert(msg: "Server error: \(msg)")
                    case .noInternet:
                        self.showAlert(msg: "No internet connection.")
                    default:
                        self.showAlert(msg: "Failed to send OTP. Please check your connection and try again.")
                    }
                }
                break
            }
        }
    }
}


