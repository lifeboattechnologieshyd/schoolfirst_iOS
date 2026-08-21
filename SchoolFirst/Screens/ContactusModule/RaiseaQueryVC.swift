//
//  RaiseaQueryVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 20/08/26.
//

import UIKit

class RaiseaQueryVC: UIViewController {

    @IBOutlet weak var SumitqueryButton: UIButton!

    @IBOutlet weak var backButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func backButtonTapped(_ sender: UIButton) {

        self.navigationController?.popViewController(animated: true)
    }

    // MARK: - Submit Query Button
    @IBAction func SubmitqueryButtonTapped(_ sender: UIButton) {

        let storyboard = UIStoryboard(
            name: "Main",
            bundle: nil
        )

        if let querySubmittedVC = storyboard.instantiateViewController(
            withIdentifier: "QuerysubmittedVC"
        ) as? QuerysubmittedVC {

            self.navigationController?.pushViewController(
                querySubmittedVC,
                animated: true
            )
        }
    }
}
