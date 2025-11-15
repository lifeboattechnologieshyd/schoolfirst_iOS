//
//  FeeSummaryVC.swift
//  SchoolFirst
//
//  Created by Lifeboat on 14/11/25.
//
import UIKit

class FeeSummaryVC: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var topVw: UIView!
    @IBOutlet weak var tblVw: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        topVw.addBottomShadow()


        tblVw.register(
            UINib(nibName: "FeeSummaryCell", bundle: nil),
            forCellReuseIdentifier: "FeeSummaryCell"
        )

        tblVw.delegate = self
        tblVw.dataSource = self
    }

    @IBAction func onClickBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    @objc func openTransactions(_ sender: UIButton) {

        if let nav = navigationController {
            for vc in nav.viewControllers {
                if vc is FeeTransactionsVC {
                    nav.popToViewController(vc, animated: true)
                    return
                }
            }
        }

        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(
            withIdentifier: "FeeTransactionsVC"
        ) as! FeeTransactionsVC

        navigationController?.pushViewController(vc, animated: true)
    }
}

extension FeeSummaryVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath)
    -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "FeeSummaryCell",
            for: indexPath
        ) as! FeeSummaryCell

        cell.transactionsButton.addTarget(
            self,
            action: #selector(openTransactions(_:)),
            for: .touchUpInside
        )

        return cell
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 984
    }
}
