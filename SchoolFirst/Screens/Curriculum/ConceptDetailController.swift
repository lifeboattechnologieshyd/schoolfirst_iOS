//
//  ConceptDetailController.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 24/10/25.
//

import UIKit
import WebKit

class ConceptDetailController: UIViewController, WKNavigationDelegate {
    @IBOutlet weak var topView: UIView!
    var concept : LessonConcept!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var lblTitle: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        lblTitle.text = concept.title
        topView.addBottomShadow()
        
        webView.scrollView.minimumZoomScale = 1.0
        webView.scrollView.maximumZoomScale = 1.0
        webView.scrollView.zoomScale = 1.0
        webView.scrollView.isScrollEnabled = true
        webView.scrollView.bounces = false

        webView.scrollView.contentMode = .scaleAspectFit

        
        let re = URLRequest(url: concept.pdfURL!)
        webView.load(re)
    }
    
    @IBAction func onClickback(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)

    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Fit PDF to width
        let js = """
        var meta = document.createElement('meta');
        meta.name = 'viewport';
        meta.content = 'width=device-width, initial-scale=0.95, maximum-scale=1.0, user-scalable=no';
        document.getElementsByTagName('head')[0].appendChild(meta);
        """
        webView.evaluateJavaScript(js, completionHandler: nil)
    }


}
