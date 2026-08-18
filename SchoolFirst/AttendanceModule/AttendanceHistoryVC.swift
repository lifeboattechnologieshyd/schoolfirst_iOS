//
//  AttendanceHistoryVC.swift
//
//  Created by vamshi krishna on 17/08/26.
//

import UIKit

class AttendanceHistoryVC: UIViewController {
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var Topview: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTopViewShadow()
        setupTableView()
    }
    
    // MARK: - Top View Shadow
    private func setupTopViewShadow() {
        Topview.layer.shadowColor = UIColor.lightGray.cgColor
        Topview.layer.shadowOpacity = 0.4
        Topview.layer.shadowOffset = CGSize(width: 0, height: 4)
        Topview.layer.shadowRadius = 2
        Topview.layer.masksToBounds = false
    }
    
    // MARK: - TableView Setup
    private func setupTableView() {
        
        tableview.delegate = self
        tableview.dataSource = self
        
        // Register Cell 1
        tableview.register(
            UINib(
                nibName: "ATNDShistoryTableViewCell1",
                bundle: nil
            ),
            forCellReuseIdentifier: "ATNDShistoryTableViewCell1"
        )
        
        // Register Cell 2
        tableview.register(
            UINib(
                nibName: "ATNDShistoryTableViewCell2",
                bundle: nil
            ),
            forCellReuseIdentifier: "ATNDShistoryTableViewCell2"
        )
        
        tableview.separatorStyle = .none
        tableview.showsVerticalScrollIndicator = false
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension AttendanceHistoryVC: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Number of Sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: - Number of Rows
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return 2
    }
    
    // MARK: - Cell For Row
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        // MARK: Cell 1
        if indexPath.row == 0 {
            
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "ATNDShistoryTableViewCell1",
                for: indexPath
            ) as! ATNDShistoryTableViewCell1
            
            cell.selectionStyle = .none
            
            return cell
        }
        
        // MARK: Cell 2
        else {
            
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "ATNDShistoryTableViewCell2",
                for: indexPath
            ) as! ATNDShistoryTableViewCell2
            
            cell.selectionStyle = .none
            
            return cell
        }
    }
    
    // MARK: - Cell Height
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        
        // Cell 1 Height
        if indexPath.row == 0 {
            return 140
        }
        
        // Cell 2 Height
        return 100
    }
}
