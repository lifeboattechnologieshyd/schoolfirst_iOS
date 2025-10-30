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

        [dateVw, reasonVw, tellusTf].forEach { view in
            view?.layer.cornerRadius = 12
            view?.layer.applyShadow(color: .black, opacity: 0.2, offset: CGSize(width: 0, height: 2), radius: 4)
        }

        [halfdayVw, fulldayVw,multipledaysVw].forEach { view in
            view?.layer.cornerRadius = 12
        }

        [userVw, singledayVw].forEach { view in
            view?.layer.cornerRadius = 12
            view?.layer.borderWidth = 1
            view?.layer.borderColor = UIColor(red: 11/255, green: 86/255, blue: 154/255, alpha: 1).cgColor // #0B569A
            view?.clipsToBounds = true
        }
    }
}

