//
//  FeedbackoverviewVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 11/10/26.
//

import UIKit

class FeedbackoverviewVC: UIViewController {

    @IBOutlet weak var Tableview: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        Tableview.separatorStyle = .none
    }

    private func setupTableView() {
        Tableview.delegate = self
        Tableview.dataSource = self
        Tableview.showsVerticalScrollIndicator = false

        // Register Nib if cell is created in a separate XIB file:
        Tableview.register(UINib(nibName: "FeedbackoverviewVCTBLVWCell", bundle: nil), forCellReuseIdentifier: "FeedbackoverviewVCTBLVWCell")
        Tableview.register(UINib(nibName: "FeedbackoverviewVCTBLVWCell2", bundle: nil), forCellReuseIdentifier: "FeedbackoverviewVCTBLVWCell2")
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension FeedbackoverviewVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FeedbackoverviewVCTBLVWCell", for: indexPath)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FeedbackoverviewVCTBLVWCell2", for: indexPath)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 250
        } else {
            return 100
        }
    }
}
