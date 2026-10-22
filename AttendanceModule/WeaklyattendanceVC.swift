//
//  WeaklyattendanceVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 21/10/26.
//

import UIKit

class WeaklyattendanceVC: UIViewController {
    
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
        
        // Register cell 1
        let nib = UINib(nibName: "WeaklyattendanceVCTBLVCLL", bundle: nil)
        Tableview.register(nib, forCellReuseIdentifier: "WeaklyattendanceVCTBLVCLL")
        
        // ✅ Register cell 2
        let nib2 = UINib(nibName: "LeaverequestsTBLVCLL2", bundle: nil)
        Tableview.register(nib2, forCellReuseIdentifier: "LeaverequestsTBLVCLL2")
        
        Tableview.tableFooterView = UIView()
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension WeaklyattendanceVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2 // ✅ Updated to 2 rows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            // First Cell
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "WeaklyattendanceVCTBLVCLL",
                for: indexPath
            ) as? WeaklyattendanceVCTBLVCLL else {
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
    
    // MARK: - Cell Heights
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 360// Height for first cell
        } else {
            return 70  // ✅ Height for second cell
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 360
        } else {
            return 70  // ✅ Height for second cell
        }
    }
}
