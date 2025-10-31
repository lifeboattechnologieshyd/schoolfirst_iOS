//
//  SingleDayViewcontroller.swift
//  SchoolFirst
//
//  Created by Lifeboat on 30/10/25.
//

import UIKit

class SingleDayViewcontroller: UIViewController {

    @IBOutlet weak var topVw: UIView!
    @IBOutlet weak var dateVw: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var halfdayButton: UIButton!
    @IBOutlet weak var fulldayButton: UIButton!
    @IBOutlet weak var halfdayVw: UIView!
    @IBOutlet weak var fulldayVw: UIView!
    @IBOutlet weak var bottonVw: UIView!
    @IBOutlet weak var tellusTf: UITextField!
    @IBOutlet weak var reasonVw: UIView!
    @IBOutlet weak var multipledaysVw: UIView!
    @IBOutlet weak var singledayVw: UIView!
    @IBOutlet weak var userVw: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        topVw.addBottomShadow()
        bottonVw.layer.applyShadow(color: .black, opacity: 0.2, offset: CGSize(width: 0, height: -2), radius: 4)

         [dateVw, reasonVw].forEach {
            $0?.layer.cornerRadius = 5
            $0?.layer.applyShadow(color: .black, opacity: 0.2, offset: CGSize(width: 0, height: 2), radius: 4)
        }

        [tellusTf, multipledaysVw].forEach {
            $0?.layer.cornerRadius = 12
            $0?.layer.applyShadow(color: .black, opacity: 0.2, offset: CGSize(width: 0, height: 2), radius: 4)
        }

        [halfdayVw, fulldayVw, multipledaysVw].forEach { $0?.layer.cornerRadius = 12 }
        [userVw, singledayVw].forEach {
            $0?.layer.cornerRadius = 12
            $0?.layer.borderWidth = 1
            $0?.layer.borderColor = UIColor(red: 11/255, green: 86/255, blue: 154/255, alpha: 1).cgColor
        }
    }

    @IBAction func halfdayButtonTapped(_ sender: UIButton) {
        let sb = UIStoryboard(name: "Attendance", bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "HalfDayViewController") as? HalfDayViewController {
            navigationController?.pushViewController(vc, animated: true)
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

