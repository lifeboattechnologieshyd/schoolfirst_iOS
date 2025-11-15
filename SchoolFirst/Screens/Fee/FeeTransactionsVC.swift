//
//  FeeTransactionsVC.swift
//  SchoolFirst
//
//  Created by Lifeboat on 14/11/25.
//
import UIKit

class FeeTransactionsVC: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var topVw: UIView!
    @IBOutlet weak var tblVw: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        topVw.addBottomShadow()


        tblVw.register(
            UINib(nibName: "TransactionsCell", bundle: nil),
            forCellReuseIdentifier: "TransactionsCell"
        )

        tblVw.delegate = self
        tblVw.dataSource = self
    }
    @IBAction func onClickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
 
}

extension FeeTransactionsVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "TransactionsCell",
            for: indexPath
        ) as! TransactionsCell

        return cell
    }

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 390
    }
}
