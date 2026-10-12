//
//  SubmitnewfeedbackVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 12/10/26.
//

import UIKit

class SubmitnewfeedbackVC: UIViewController {

    @IBOutlet weak var Tableview: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    private func setupTableView() {
        Tableview.delegate = self
        Tableview.dataSource = self
        Tableview.showsVerticalScrollIndicator = false

        Tableview.register(UINib(nibName: "FeedbacksubmitVCTBLVWCell1", bundle: nil), forCellReuseIdentifier: "FeedbacksubmitVCTBLVWCell1")
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension SubmitnewfeedbackVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedbacksubmitVCTBLVWCell1", for: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 800
    }
}
