//
//  MychiledattendanceVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 18/08/26.
//

import UIKit

class MychiledattendanceVC: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var Topview: UIView!
    @IBOutlet weak var Tableview: UITableView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTopViewShadow()
        setupTableView()
    }
    
    // MARK: - Top View Setup
    
    private func setupTopViewShadow() {
        Topview.layer.shadowColor = UIColor.lightGray.cgColor
        Topview.layer.shadowOpacity = 0.4
        Topview.layer.shadowOffset = CGSize(width: 0, height: 4)
        Topview.layer.shadowRadius = 2
        Topview.layer.masksToBounds = false
    }
    
    // MARK: - Table View Setup
    
    private func setupTableView() {
        
        Tableview.delegate = self
        Tableview.dataSource = self
        Tableview.separatorStyle = .none
        
        // MARK: Register Attendance Cell
        
        Tableview.register(
            UINib(
                nibName: "ATNDmychiledattendanceTBLVCll",
                bundle: nil
            ),
            forCellReuseIdentifier: "ATNDmychiledattendanceTBLVCll"
        )
        
        // MARK: Register Attendance History Cell
        
        Tableview.register(
            UINib(
                nibName: "ATNDShistoryTableViewCell2",
                bundle: nil
            ),
            forCellReuseIdentifier: "ATNDShistoryTableViewCell2"
        )
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension MychiledattendanceVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(
        in tableView: UITableView
    ) -> Int {
        return 1
    }
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        
        // Row 0: Attendance/calendar cell
        // Row 1 and 2: Attendance history cells
        return 3
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        // MARK: - Index 0: Attendance Calendar Cell
        
        if indexPath.row == 0 {
            
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "ATNDmychiledattendanceTBLVCll",
                for: indexPath
            ) as? ATNDmychiledattendanceTBLVCll else {
                return UITableViewCell()
            }
            
            cell.selectionStyle = .none
            
            return cell
        }
        
        // MARK: - Index 1 and 2: Attendance History Cell
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ATNDShistoryTableViewCell2",
            for: indexPath
        ) as? ATNDShistoryTableViewCell2 else {
            return UITableViewCell()
        }
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        
        if indexPath.row == 0 {
            return 600
        }
        
        // Index 1 and index 2
        return 96
    }
}
