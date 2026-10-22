//
//  LeaveRejectVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 21/10/26.
//

import UIKit

class LeaveRejectVC: UIViewController {
    
    @IBOutlet weak var Tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    // MARK: - Setup TableView
    private func setupTableView() {
        Tableview.delegate = self
        Tableview.dataSource = self
        Tableview.separatorStyle = .none
        Tableview.showsVerticalScrollIndicator = false
        
        // Register cell with identifier
        let nib = UINib(nibName: "LeaverejectTBLVCLL", bundle: nil)
        Tableview.register(nib, forCellReuseIdentifier: "LeaverejectTBLVCLL")
        
        Tableview.tableFooterView = UIView()
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension LeaveRejectVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "LeaverejectTBLVCLL",
            for: indexPath
        ) as? LeaverejectTBLVCLL else {
            return UITableViewCell()
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    // MARK: - Cell Height (800)
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 800
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 800
    }
}
