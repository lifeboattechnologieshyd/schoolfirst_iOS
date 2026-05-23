//
//  WebViewController.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 10/12/25.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var webView: WKWebView!
    var type = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        if type == "PP" {
            lblName.text = "Privacy Policy"
            let url = "https://www.schoolfirst.ai/privacy-policy.html"
            self.webView.load(URLRequest(url: URL(string: url)!))
        }else if type == "TC" {
            lblName.text = "Terms & Conditions"
            let url = "https://www.schoolfirst.ai/terms-and-conditions.html"
            self.webView.load(URLRequest(url: URL(string: url)!))
        }

    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
