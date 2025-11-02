//
//  SubmitLeaveViewController.swift
//  SchoolFirst
//
//  Created by Lifeboat on 30/10/25.
//

import UIKit

class SubmitLeaveViewController: UIViewController {

    @IBOutlet weak var multipleVw: UIView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var singleVw: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var bottomVw: UIView!
    @IBOutlet weak var multipledaysImg: UIImageView!
    @IBOutlet weak var singledayImg: UIImageView!
    @IBOutlet weak var userVw: UIView!
    @IBOutlet weak var topVw: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        topVw.addBottomShadow()
        
         [singleVw, multipleVw].forEach { view in
            view?.layer.cornerRadius = 12
            view?.layer.shadowColor = UIColor.black.cgColor
            view?.layer.shadowOpacity = 0.2
            view?.layer.shadowOffset = CGSize(width: 0, height: 2)
            view?.layer.shadowRadius = 4
            view?.layer.masksToBounds = false
        }

         bottomVw.layer.applyShadow(color: .black, opacity: 0.2, offset: CGSize(width: 0, height: -2), radius: 4)
        
         userVw.layer.cornerRadius = 25
        userVw.layer.borderWidth = 1
        userVw.layer.borderColor = UIColor(red: 11/255, green: 86/255, blue: 154/255, alpha: 1).cgColor
        userVw.clipsToBounds = true

         let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleDayTapped))
        singledayImg.isUserInteractionEnabled = true
        singledayImg.addGestureRecognizer(singleTap)

         let multipleTap = UITapGestureRecognizer(target: self, action: #selector(multipleDayTapped))
        multipledaysImg.isUserInteractionEnabled = true
        multipledaysImg.addGestureRecognizer(multipleTap)
    }

     @objc func singleDayTapped() {
        let storyboard = UIStoryboard(name: "Attendance", bundle: nil)
        if let nextVC = storyboard.instantiateViewController(withIdentifier: "SingleDayViewcontroller") as? SingleDayViewcontroller {
            navigationController?.pushViewController(nextVC, animated: true)
        }
    }

    @objc func multipleDayTapped() {
        let storyboard = UIStoryboard(name: "Attendance", bundle: nil)
        if let nextVC = storyboard.instantiateViewController(withIdentifier: "MultipleDaysViewController") as? MultipleDaysViewController {
            navigationController?.pushViewController(nextVC, animated: true)
        }
    }

     @IBAction func backButtonTapped(_ sender: UIButton) {
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
}

 extension CALayer {
    func applyShadow(color: UIColor, opacity: Float, offset: CGSize, radius: CGFloat) {
        shadowColor = color.cgColor
        shadowOpacity = opacity
        shadowOffset = offset
        shadowRadius = radius
        masksToBounds = false
    }
}

