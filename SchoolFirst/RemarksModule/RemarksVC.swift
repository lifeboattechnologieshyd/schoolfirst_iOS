//
//  RemarksVC.swift
//  SchoolFirst
//

import UIKit

class RemarksVC: UIViewController {

    @IBOutlet weak var Tableview: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        Tableview.delegate = self
        Tableview.dataSource = self
        Tableview.separatorStyle = .none
        Tableview.showsVerticalScrollIndicator = false

        Tableview.register(
            UINib(nibName: "RemarksTBLVCll1", bundle: nil),
            forCellReuseIdentifier: "RemarksTBLVCll1"
        )

        Tableview.register(
            UINib(nibName: "RemarksTBLVCll2", bundle: nil),
            forCellReuseIdentifier: "RemarksTBLVCll2"
        )
    }
}

extension RemarksVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "RemarksTBLVCll1",
                for: indexPath
            ) as! RemarksTBLVCll1

            cell.selectionStyle = .none
            cell.updateCounts(academic: 3, behaviour: 1, newCount: 2)

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "RemarksTBLVCll2",
                for: indexPath
            )

            cell.selectionStyle = .none
            return cell
        }
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        if indexPath.row == 0 {
            return 334
        } else {
            return 160
            
        }
    }
}
