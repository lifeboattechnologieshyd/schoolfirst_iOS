//
//  TranportParentDashbordVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 28/07/26.
//

import UIKit

class TranportParentDashbordVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var Tableview: UITableView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    // MARK: - Setup
    private func setupTableView() {
        Tableview.delegate   = self
        Tableview.dataSource = self
        
        Tableview.register(
            UINib(nibName: "TRNSPTdashbordUITableViewCell1", bundle: nil),
            forCellReuseIdentifier: "TRNSPTdashbordUITableViewCell1"
        )
        
        Tableview.separatorStyle              = .none
        Tableview.showsVerticalScrollIndicator = false
    }
}

// MARK: - UITableViewDelegate & DataSource
extension TranportParentDashbordVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
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
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "TRNSPTdashbordUITableViewCell1",
            for: indexPath
        ) as! TRNSPTdashbordUITableViewCell1
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 1000
    }
}
