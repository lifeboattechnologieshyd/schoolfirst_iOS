//
//  SubmitLeaveViewController.swift
//  SchoolFirst
//
//  Created by Lifeboat on 30/10/25.
//

import UIKit

class SubmitLeaveViewController: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var topVw: UIView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var tblVw: UITableView!
    @IBOutlet weak var bottomVw: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topVw.addBottomShadow(shadowOpacity: 0.15, shadowRadius: 3, shadowHeight: 4)
        bottomVw.addTopShadow()

        tblVw.register(
            UINib(nibName: "SubmitLeaveTableCell", bundle: nil),
            forCellReuseIdentifier: "SubmitLeaveTableCell"
        )

        tblVw.delegate = self
        tblVw.dataSource = self
    }
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

}

extension SubmitLeaveViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "SubmitLeaveTableCell",
            for: indexPath
        ) as! SubmitLeaveTableCell

        return cell
    }

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 802
    }
}
extension UIView {
    
    func addTopShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: -3)
    }
}
