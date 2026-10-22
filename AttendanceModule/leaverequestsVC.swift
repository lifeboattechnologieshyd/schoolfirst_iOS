//
//  leaverequestsVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 19/10/26.
//

import UIKit

class leaverequestsVC: UIViewController {
    
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
        
        // ✅ Register First Cell
        let nib1 = UINib(nibName: "LeaverequestsTBLVCLL1", bundle: nil)
        Tableview.register(nib1, forCellReuseIdentifier: "LeaverequestsTBLVCLL1")
        
        // ✅ Register Second Cell
        let nib2 = UINib(nibName: "LeaverequestsTBLVCLL2", bundle: nil)
        Tableview.register(nib2, forCellReuseIdentifier: "LeaverequestsTBLVCLL2")
        
        Tableview.tableFooterView = UIView()
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension leaverequestsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2 // ✅ Updated to return 2 rows (1 for each cell)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            // ✅ First Cell
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "LeaverequestsTBLVCLL1",
                for: indexPath
            ) as? LeaverequestsTBLVCLL1 else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            return cell
            
        } else {
            // ✅ Second Cell
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "LeaverequestsTBLVCLL2",
                for: indexPath
            ) as? LeaverequestsTBLVCLL2 else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            return cell
        }
    }
    
    // MARK: - Cell Height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 200 // Height for the first cell
        } else {
            return 80  // ✅ Height for the second cell
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 200
        } else {
            return 80
        }
    }
}
