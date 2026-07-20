//
//  CustompaymentVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 23/06/26.
//

import UIKit

class CustompaymentVC: UIViewController {

    @IBOutlet weak var BackButton: UIButton!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var TopView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTopViewShadow()
        setupTableView()
    }
    @IBAction func BackButtonTapped(_ sender: UIButton) {

        if let nav = navigationController {

            nav.popViewController(
                animated: true
            )

        } else {

            dismiss(
                animated: true
            )
        }
    }


    // MARK: Shadow

    private func setupTopViewShadow() {

        TopView.layer.shadowColor =
        UIColor.lightGray.cgColor

        TopView.layer.shadowOpacity = 0.4

        TopView.layer.shadowOffset =
        CGSize(width: 0, height: 4)

        TopView.layer.shadowRadius = 2

        TopView.layer.masksToBounds = false
    }

    // MARK: Table

    private func setupTableView() {

        tableview.delegate = self
        tableview.dataSource = self

        tableview.separatorStyle = .none

        tableview.register(
            UINib(
                nibName:
                "CustompaymentVCTableViewCell",
                bundle: nil
            ),
            forCellReuseIdentifier:
            "CustompaymentVCTableViewCell"
        )
    }
}

// MARK: TableView

extension CustompaymentVC:
UITableViewDelegate,
UITableViewDataSource {

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {

        return 1
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell =
        tableView.dequeueReusableCell(
            withIdentifier:
            "CustompaymentVCTableViewCell",
            for: indexPath
        ) as! CustompaymentVCTableViewCell

        cell.selectionStyle = .none

        // OFF → Back ParentfeeVC

        cell.onSwitchOff = { [weak self] in

            if let nav =
                self?.navigationController {

                nav.popViewController(
                    animated: true
                )

            } else {

                self?.dismiss(
                    animated: true
                )
            }
        }

        // View Full Schedule

        cell.onViewFullScheduleTap = {
            [weak self] in

            let storyboard =
            UIStoryboard(
                name: "Main",
                bundle: nil
            )

            if let vc =
                storyboard.instantiateViewController(
                    withIdentifier:
                    "FeefulltransactionVC"
                ) as? FeefulltransactionVC {

                self?.navigationController?
                    .pushViewController(
                        vc,
                        animated: true
                    )
            }
        }

        // View All Transactions

        cell.onViewAllTransactionsTap = {
            [weak self] in

            let storyboard =
            UIStoryboard(
                name: "Main",
                bundle: nil
            )

            if let vc =
                storyboard.instantiateViewController(
                    withIdentifier:
                    "FeealltransactionVC"
                ) as? FeealltransactionVC {

                self?.navigationController?
                    .pushViewController(
                        vc,
                        animated: true
                    )
            }
        }

        return cell
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {

        return 1000
    }
}
