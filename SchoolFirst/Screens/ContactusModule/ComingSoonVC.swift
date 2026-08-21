//
//  ComingSoonVC.swift
//  SchoolFirst
//
//  Created by Lifeboat on 18/11/25.
//

import UIKit

class ComingSoonVC: UIViewController {

    @IBOutlet weak var RaiseQueryButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var RaisequeryButton: UIButton!
    @IBOutlet weak var topVw: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Back Button
    @IBAction func backButtonTapped(_ sender: UIButton) {

        self.navigationController?.popViewController(animated: true)
    }

    // MARK: - Raise Query Button
    @IBAction func raiseQueryButtonTapped(_ sender: UIButton) {

        let storyboard = UIStoryboard(
            name: "Main",
            bundle: nil
        )

        if let raiseQueryVC = storyboard.instantiateViewController(
            withIdentifier: "RaiseaQueryVC"
        ) as? RaiseaQueryVC {

            self.navigationController?.pushViewController(
                raiseQueryVC,
                animated: true
            )
        }
    }
}
