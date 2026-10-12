//
//  FeedbackstatusVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 12/10/26.
//

import UIKit

class FeedbackstatusVC: UIViewController {

    @IBOutlet weak var Tableview: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    private func setupTableView() {
        Tableview.delegate = self
        Tableview.dataSource = self
        Tableview.showsVerticalScrollIndicator = false

        Tableview.register(UINib(nibName: "FeedbacksummuryTBLVWCell", bundle: nil), forCellReuseIdentifier: "FeedbacksummuryTBLVWCell")
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension FeedbackstatusVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedbacksummuryTBLVWCell", for: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 1000
    }
}
