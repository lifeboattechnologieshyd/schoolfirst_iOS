//
//  StudentprofileVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 21/05/26.
//

import UIKit

class StudentprofileVC: UIViewController {

    @IBOutlet weak var TableView: UITableView!

    let cellIdentifier = "StudentdetailsTableViewCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        TableView.delegate = self
        TableView.dataSource = self

        // Register XIB
        TableView.register(UINib(nibName: "StudentdetailsTableViewCell", bundle: nil),
                           forCellReuseIdentifier: cellIdentifier)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension StudentprofileVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 360
        
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,
                                                 for: indexPath) as! StudentdetailsTableViewCell

        return cell
    }
}
