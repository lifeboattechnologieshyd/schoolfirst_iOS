//
//  ApprovedleavedetailsVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 16/10/26.
//

import UIKit

class ApprovedleavedetailsVC: UIViewController {
    
    @IBOutlet weak var Tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
    }
    
    // MARK: - TableView Setup
    private func setupTableView() {
        Tableview.delegate = self
        Tableview.dataSource = self
        Tableview.separatorStyle = .none
        Tableview.showsVerticalScrollIndicator = false
        
        Tableview.register(
            UINib(nibName: "ApprovedleavedetailsTBLVCLL", bundle: nil),
            forCellReuseIdentifier: "ApprovedleavedetailsTBLVCLL"
        )
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension ApprovedleavedetailsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "ApprovedleavedetailsTBLVCLL",
            for: indexPath
        )
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 800
    }
}
