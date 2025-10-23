//
//  ConceptDetailController.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 24/10/25.
//

import UIKit
import WebKit

class ConceptDetailController: UIViewController {
    @IBOutlet weak var topView: UIView!
    var concept : LessonConcept!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var lblTitle: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        lblTitle.text = concept.title
        topView.addBottomShadow()
        let re = URLRequest(url: concept.pdfURL!)
        webView.load(re)
    }
    
    @IBAction func onClickback(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)

    }
    

}
