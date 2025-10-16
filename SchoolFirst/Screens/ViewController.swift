//
//  ViewController.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 13/06/25.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtFieldMobile: UITextField!
    @IBOutlet weak var lblPrivacy: UILabel!
    @IBOutlet weak var btnLogin: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setText()
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
        if self.txtFieldMobile.text!.isValidIndianMobile(){
            self.getUserDetails(mobile: self.txtFieldMobile.text!)
        }else{
            self.showAlert(msg: "please enter valid mobile number")
        }
    }
    
    func getUserDetails(mobile: String) {
        let payload = [
            "mobile": mobile
        ]
        NetworkManager.shared.request(urlString: API.SENDOTP, method: .POST, parameters: payload) { (result: Result<APIResponse<MobileCheckResponse>, NetworkError>) in
            switch result {
            case .success(let info):
                if info.success {
                    if info.data!.password_required! {
                        DispatchQueue.main.async {
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginController") as? LoginController
                            vc?.mobile = self.txtFieldMobile.text!
                            vc?.username = info.data!.username!
                            self.navigationController?.pushViewController(vc!, animated: true)
                        }
                    }else{
                        DispatchQueue.main.async {
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "OTPViewController") as? OTPViewController
                            vc?.mobile = self.txtFieldMobile.text!
                            self.navigationController?.pushViewController(vc!, animated: true)
                        }
                    }
                }else{
                    self.showAlert(msg: "Something wrong")
                }
                break
            case .failure(let error):
                self.showAlert(msg: error.localizedDescription)
                break
            }
        }
    }
}


