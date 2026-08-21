//
//  QuerysubmittedVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 20/08/26.
//

import UIKit

class QuerysubmittedVC: UIViewController {

    @IBOutlet weak var Raiseanotherquery: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var ViewthisqueryButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {

        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func RaiseanotherqueryTapped(_ sender: UIButton) {

        let storyboard = UIStoryboard(
            name: "Main",
            bundle: nil
        )

        if let RaiseaQueryVC = storyboard.instantiateViewController(
            withIdentifier: "RaiseaQueryVC"
        ) as? RaiseaQueryVC {

            self.navigationController?.pushViewController(
                RaiseaQueryVC,
                animated: true
            )
        }
    }
    // MARK: - View This Query Button
    @IBAction func ViewthisqueryButtonTapped(_ sender: UIButton) {

        let storyboard = UIStoryboard(
            name: "Main",
            bundle: nil
        )

        if let queriesHistoryVC = storyboard.instantiateViewController(
            withIdentifier: "QuerieshistoryVC"
        ) as? QuerieshistoryVC {

            self.navigationController?.pushViewController(
                queriesHistoryVC,
                animated: true
            )
        }
    }
}
