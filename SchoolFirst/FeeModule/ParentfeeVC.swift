//
//  ParentfeeVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 23/06/26.
//

import UIKit

class ParentfeeVC: UIViewController {

    @IBOutlet weak var BackButton: UIButton!
    @IBOutlet weak var TopView: UIView!
    @IBOutlet weak var tableview: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTopViewShadow()
        setupTableView()
    }

    // MARK: TableView Setup

    private func setupTableView() {

        tableview.delegate = self
        tableview.dataSource = self

        tableview.register(
            UINib(
                nibName: "ParentfeeVCTableViewCell",
                bundle: nil
            ),
            forCellReuseIdentifier:
                "ParentfeeVCTableViewCell"
        )

        tableview.separatorStyle = .none
        tableview.showsVerticalScrollIndicator = false
    }

    // MARK: Top Shadow

    private func setupTopViewShadow() {

        TopView.layer.shadowColor =
        UIColor.lightGray.cgColor

        TopView.layer.shadowOpacity = 0.4

        TopView.layer.shadowOffset =
        CGSize(width: 0, height: 4)

        TopView.layer.shadowRadius = 2

        TopView.layer.masksToBounds = false
    }

    @IBAction func BackButtonTapped(
        _ sender: UIButton
    ) {

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
}

// MARK: - TableView

extension ParentfeeVC:
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
                "ParentfeeVCTableViewCell",
            for: indexPath
        ) as! ParentfeeVCTableViewCell

        cell.selectionStyle = .none

        // Switch → CustompaymentVC

        cell.onSwitchOn = { [weak self] in

            let storyboard =
            UIStoryboard(
                name: "Main",
                bundle: nil
            )

            if let vc =
                storyboard.instantiateViewController(
                    withIdentifier:
                        "CustompaymentVC"
                ) as? CustompaymentVC {

                self?.navigationController?
                    .pushViewController(
                        vc,
                        animated: true
                    )
            }
        }

        // View Schedule → FeefulltransactionVC

        cell.onViewScheduleTap = { [weak self] in

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

        // View All Transactions → FeealltransactionVC

        cell.onViewAllTransactionTap = { [weak self] in

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
