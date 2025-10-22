//
//  DateViewController.swift
//  SchoolFirst
//
//  Created by Lifeboat on 22/10/25.
//

import  UIKit

class DateViewController: UIViewController {
    
    @IBOutlet weak var nextButton: UIView!
    @IBOutlet weak var BackButton: UIButton!
    @IBOutlet weak var topbarView: UIView!
    @IBOutlet weak var todatView: UIView!
    @IBOutlet weak var resumeView: UIView!
    @IBOutlet weak var blueView: UIView!
    @IBOutlet weak var blueteoView: UIView!
    @IBOutlet weak var sundayoneView: UIView!
    @IBOutlet weak var sundaytwoView: UIView!
    @IBOutlet weak var sundaythreeView: UIView!
    @IBOutlet weak var sundayfourView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyBottomShadow(to: topbarView)
        
        applyCustomBorder(to: todatView, colorHex: "#0B569A", borderWidth: 1)
        
        let views: [UIView] = [resumeView, blueView, blueteoView,
                               sundayoneView, sundaytwoView, sundaythreeView, sundayfourView]
        
        for view in views {
            applyRadiusAndShadow(to: view)
        }
    }
    
    func applyRadiusAndShadow(to view: UIView) {
        view.layer.cornerRadius = 6
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.25
        view.layer.shadowOffset = CGSize(width: 0, height: 3)
        view.layer.shadowRadius = 6
    }
    
    func applyBottomShadow(to view: UIView) {
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.25
        view.layer.shadowOffset = CGSize(width: 0, height: 3)
        view.layer.shadowRadius = 6
    }
    
    func applyCustomBorder(to view: UIView, colorHex: String, borderWidth: CGFloat) {
        view.layer.cornerRadius = 6
        view.layer.masksToBounds = false
        
        view.layer.borderColor = UIColor(hex: colorHex)?.cgColor
        view.layer.borderWidth = borderWidth
        
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.25
        view.layer.shadowOffset = CGSize(width: 0, height: 3)
        view.layer.shadowRadius = 6
    }
    @IBAction func BackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "VocabBees", bundle: nil)
        if let gradeVC = storyboard.instantiateViewController(withIdentifier: "DailyChallengeViewController") as? DailyChallengeViewController {
            self.navigationController?.pushViewController(gradeVC, animated: true)
        }
        
    }
}
