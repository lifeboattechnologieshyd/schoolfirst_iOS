//
//  ApprovedleavedetailsVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 16/10/26.
//

import UIKit

class ApprovedleavedetailsVC: UIViewController {
    
    @IBOutlet weak var DateLabel: UILabel!
    @IBOutlet weak var BackButton: UIButton!
    @IBOutlet weak var Tableview: UITableView!
    
    var leaveItem: LeaveListItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupBackButton()
    }
    
    // MARK: - Back Button
    private func setupBackButton() {
        BackButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
    }
    
    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
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
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ApprovedleavedetailsTBLVCLL",
            for: indexPath
        ) as? ApprovedleavedetailsTBLVCLL else {
            return UITableViewCell()
        }
        
        cell.selectionStyle = .none
        if let leaveItem = leaveItem {
            cell.configure(with: leaveItem)
        }
        return cell
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 800
    }
}
