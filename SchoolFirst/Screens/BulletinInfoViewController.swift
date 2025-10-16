//
//  BulletinInfoViewController.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 15/09/25.
//

import UIKit

class BulletinInfoViewController: UIViewController {

    @IBOutlet weak var tblVw: UITableView!
    var bulletin : Bulletin!
    override func viewDidLoad() {
        super.viewDidLoad()

        tblVw.register(UINib(nibName: "BulletinInfoCell", bundle: nil), forCellReuseIdentifier: "BulletinInfoCell")
        tblVw.delegate = self
        tblVw.dataSource = self
    }
    @IBAction func onClickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension BulletinInfoViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblVw.dequeueReusableCell(withIdentifier: "BulletinInfoCell") as! BulletinInfoCell
        cell.config(bulletin: self.bulletin)
        return cell
    }
}
